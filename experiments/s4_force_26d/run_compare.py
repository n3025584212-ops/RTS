from __future__ import annotations

import json
import urllib.request
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.feature_selection import mutual_info_regression
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVR

import dkqkar_v5s2_model as dk

HERE = Path(__file__).resolve().parent
COHORT_PATH = HERE / "DEV400_00_fresh_cohort_400.csv"
RAW_XLSX = HERE / "Thickness-flatness.xlsx"
RAW_URL = "https://raw.githubusercontent.com/DGlql/CRD/main/Thickness-flatness.xlsx"
OUT = HERE / "results"
OUT.mkdir(exist_ok=True)

BASE25 = [
    "Entry set thickness", "width", "Entry actual thickness",
    "S1 rolling forces", "S2 rolling forces", "S3rolling forces",
    "S1 bending force", "S2 bending force", "S3 bending force",
    "S4 bending force", "S1 rolling speed", "S2 rolling speed",
    "S3 rolling speed", "S4 rolling speed", "S1 back tension",
    "S2 back tension", "S3 back tension", "S4 back tension",
    "S1 front tension", "S2 front tension", "S3 front tension",
    "S4 front tension", "S5 bending force", "S5 rolling speed",
    "S5 back tension",
]
PLUS26 = BASE25[:6] + ["S4 rolling forces"] + BASE25[6:]
TARGET = "S5 rolling forces"
SPEC_ORDER = [
    "1.8|0.181|818",
    "2.75|0.282|794",
    "2.75|0.282|919",
    "3.5|0.916|920",
    "3.5|1.022|1250",
    "3|0.333|853",
    "3|0.352|1000",
    "3|0.461|926",
]

def norm_spec(v):
    return str(v).replace(".0|", "|").replace("|818.0", "|818").replace("|794.0", "|794").replace("|919.0", "|919").replace("|920.0", "|920").replace("|1250.0", "|1250").replace("|853.0", "|853").replace("|1000.0", "|1000").replace("|926.0", "|926")

def load_augmented():
    cohort = pd.read_csv(COHORT_PATH)
    urllib.request.urlretrieve(RAW_URL, RAW_XLSX)
    raw = pd.read_excel(RAW_XLSX)
    required_raw = ["S5 bending force", "S5 rolling speed", "S5 back tension", "S4 rolling forces", TARGET]
    missing = [c for c in required_raw if c not in raw.columns]
    if missing:
        raise RuntimeError(f"CRD raw file missing required columns: {missing}")

    probe_cols = [
        "Entry set thickness", "width", "Entry actual thickness",
        "S1 rolling forces", "S2 rolling forces", "S3rolling forces",
        "S4 rolling forces", TARGET,
    ]
    best = None
    for offset in range(-4, 5):
        pos = cohort["source_excel_row"].astype(int).to_numpy() + offset
        if pos.min() < 0 or pos.max() >= len(raw):
            continue
        cand = raw.iloc[pos].reset_index(drop=True)
        diffs = []
        ok = True
        for c in probe_cols:
            a = pd.to_numeric(cohort[c], errors="coerce").to_numpy(float)
            b = pd.to_numeric(cand[c], errors="coerce").to_numpy(float)
            if not (np.isfinite(a).all() and np.isfinite(b).all()):
                ok = False
                break
            diffs.append(float(np.max(np.abs(a-b))))
        score = max(diffs) if ok else np.inf
        if best is None or score < best[0]:
            best = (score, offset, cand)
    if best is None or best[0] > 1e-8:
        raise RuntimeError(f"Could not align source_excel_row to CRD rows; best={None if best is None else best[:2]}")
    score, offset, cand = best
    for c in ["S5 bending force", "S5 rolling speed", "S5 back tension"]:
        cohort[c] = pd.to_numeric(cand[c], errors="raise").to_numpy(float)

    for c in PLUS26 + [TARGET]:
        cohort[c] = pd.to_numeric(cohort[c], errors="raise")
    if not np.isfinite(cohort[PLUS26 + [TARGET]].to_numpy(float)).all():
        raise RuntimeError("Non-finite values in augmented cohort.")

    counts = cohort["spec_key"].value_counts().to_dict()
    if sorted(counts.values()) != [50]*8:
        raise RuntimeError(f"Expected 8 x 50 cohort, got {counts}")
    return cohort, offset, score, raw

def make_4fold_indices(df):
    folds = [list() for _ in range(4)]
    for spec in SPEC_ORDER:
        idx = df.index[df["spec_key"].astype(str) == spec].to_numpy()
        if len(idx) != 50:
            raise RuntimeError(f"{spec}: expected 50 rows, got {len(idx)}")
        parts = np.array_split(idx, 4)
        if [len(x) for x in parts] != [13,13,12,12]:
            raise RuntimeError("Unexpected split sizes")
        for f,p in enumerate(parts):
            folds[f].extend(p.tolist())
    return [np.array(v, dtype=int) for v in folds]

def metrics(y, p):
    return {
        "rmse": float(mean_squared_error(y, p) ** 0.5),
        "mae": float(mean_absolute_error(y, p)),
        "r2": float(r2_score(y, p)),
    }

def run_dk_4fold(df, features, label):
    val_folds = make_4fold_indices(df)
    rows = []
    pooled_y, pooled_p = [], []
    selected = []
    for f, va in enumerate(val_folds, start=1):
        tr = np.setdiff1d(df.index.to_numpy(), va)
        dk.FEATURES = list(features)
        model = dk.DKQKARV5S2()
        model.fit(df.loc[tr, features], df.loc[tr, TARGET])
        pred = model.predict(df.loc[va, features])
        y = df.loc[va, TARGET].to_numpy(float)
        m = metrics(y, pred)
        rows.append({"model":label,"scheme":"4fold","fold":f,"n_train":len(tr),"n_test":len(va),**m})
        pooled_y.extend(y.tolist()); pooled_p.extend(pred.tolist())
        selected.append({"model":label,"scheme":"4fold","fold":f,"selected_features":" | ".join(model.selected_features),"theta":" | ".join(f"{x:.8g}" for x in model.theta)})
    mean = {k:float(np.mean([r[k] for r in rows])) for k in ("rmse","mae","r2")}
    std = {k:float(np.std([r[k] for r in rows], ddof=1)) for k in ("rmse","mae","r2")}
    return rows, mean, std, metrics(np.array(pooled_y), np.array(pooled_p)), selected

def run_rbf_4fold(df, features, label):
    val_folds = make_4fold_indices(df)
    rows=[]; pooled_y=[]; pooled_p=[]
    for f, va in enumerate(val_folds, start=1):
        tr=np.setdiff1d(df.index.to_numpy(), va)
        sc=StandardScaler().fit(df.loc[tr,features])
        Xtr=sc.transform(df.loc[tr,features]); Xva=sc.transform(df.loc[va,features])
        reg=SVR(kernel="rbf", C=100.0, epsilon=0.01, gamma=0.01)
        reg.fit(Xtr, df.loc[tr,TARGET])
        pred=reg.predict(Xva); y=df.loc[va,TARGET].to_numpy(float)
        m=metrics(y,pred)
        rows.append({"model":label,"scheme":"4fold","fold":f,"n_train":len(tr),"n_test":len(va),**m})
        pooled_y.extend(y.tolist()); pooled_p.extend(pred.tolist())
    mean={k:float(np.mean([r[k] for r in rows])) for k in ("rmse","mae","r2")}
    std={k:float(np.std([r[k] for r in rows],ddof=1)) for k in ("rmse","mae","r2")}
    return rows, mean, std, metrics(np.array(pooled_y),np.array(pooled_p))

def run_loso(df, features, label):
    rows=[]; selected=[]
    for i,spec in enumerate(SPEC_ORDER, start=1):
        va=df.index[df["spec_key"].astype(str)==spec].to_numpy()
        tr=df.index[df["spec_key"].astype(str)!=spec].to_numpy()
        dk.FEATURES=list(features)
        model=dk.DKQKARV5S2()
        model.fit(df.loc[tr,features],df.loc[tr,TARGET])
        pred=model.predict(df.loc[va,features]); y=df.loc[va,TARGET].to_numpy(float)
        m=metrics(y,pred)
        rows.append({"model":label,"scheme":"LOSO","fold":i,"held_out_spec":spec,"n_train":len(tr),"n_test":len(va),**m})
        selected.append({"model":label,"scheme":"LOSO","fold":i,"held_out_spec":spec,"selected_features":" | ".join(model.selected_features),"theta":" | ".join(f"{x:.8g}" for x in model.theta)})
    macro={k:float(np.mean([r[k] for r in rows])) for k in ("rmse","mae","r2")}
    return rows, macro, selected

df, offset, align_error, raw = load_augmented()

corr = float(df["S4 rolling forces"].corr(df[TARGET]))
mi = float(mutual_info_regression(df[["S4 rolling forces"]].to_numpy(), df[TARGET].to_numpy(), random_state=20250621)[0])
redundancy = {}
for c in BASE25:
    redundancy[c] = float(abs(df["S4 rolling forces"].corr(df[c])))
top_redundancy = sorted(redundancy.items(), key=lambda x:x[1], reverse=True)[:8]

all_fold_rows=[]; all_selected=[]; summary={}
for features,label in [(BASE25,"DKQKAR_25D"),(PLUS26,"DKQKAR_26D_S4RF")]:
    rows,mean,std,pooled,selected=run_dk_4fold(df,features,label)
    all_fold_rows += rows; all_selected += selected
    loso_rows,loso_macro,loso_selected=run_loso(df,features,label)
    all_fold_rows += loso_rows; all_selected += loso_selected
    summary[label]={"input_dim":len(features),"four_fold_mean":mean,"four_fold_std":std,"four_fold_pooled":pooled,"loso_macro":loso_macro}

for features,label in [(BASE25,"RBF_SVR_25D"),(PLUS26,"RBF_SVR_26D_S4RF")]:
    rows,mean,std,pooled=run_rbf_4fold(df,features,label)
    all_fold_rows += rows
    summary[label]={"input_dim":len(features),"four_fold_mean":mean,"four_fold_std":std,"four_fold_pooled":pooled}

m25=summary["DKQKAR_25D"]["four_fold_mean"]
m26=summary["DKQKAR_26D_S4RF"]["four_fold_mean"]
summary["comparison"]={
    "delta_rmse_26_minus_25": m26["rmse"]-m25["rmse"],
    "rmse_change_pct": (m26["rmse"]-m25["rmse"])/m25["rmse"]*100.0,
    "delta_mae_26_minus_25": m26["mae"]-m25["mae"],
    "delta_r2_26_minus_25": m26["r2"]-m25["r2"],
    "paper_25d_rmse":19.205,
    "reproduced_25d_rmse":m25["rmse"],
    "paper_rmse_abs_gap":abs(m25["rmse"]-19.205),
    "baseline_reproduction_within_0_05":abs(m25["rmse"]-19.205)<=0.05,
    "s4_rolling_force_target_pearson":corr,
    "s4_rolling_force_target_mutual_info":mi,
    "s4_rolling_force_top_abs_correlations_with_base25":top_redundancy,
    "source_excel_row_iloc_offset":offset,
    "source_alignment_max_abs_error":align_error,
}
summary["decision_rule"]="Treat 26D as supported only if it improves 4-fold metrics without materially worsening LOSO; do not overwrite the frozen 25D paper model solely from one point estimate."

pd.DataFrame(all_fold_rows).to_csv(OUT/"fold_metrics.csv",index=False)
pd.DataFrame(all_selected).to_csv(OUT/"selected_quantum_features.csv",index=False)
df.to_csv(OUT/"cohort_400_augmented.csv",index=False)
with (OUT/"comparison_summary.json").open("w",encoding="utf-8") as f:
    json.dump(summary,f,ensure_ascii=False,indent=2)

print(json.dumps(summary,ensure_ascii=False,indent=2))
