from __future__ import annotations

import json, urllib.request
from pathlib import Path
import numpy as np, pandas as pd
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.svm import SVR
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score

import dkqkar_v5s2_model as dk

HERE=Path(__file__).resolve().parent
df=pd.read_csv(HERE/"DEV400_00_fresh_cohort_400.csv")
RAW_URL="https://raw.githubusercontent.com/DGlql/CRD/main/Thickness-flatness.xlsx"
raw_path=HERE/"Thickness-flatness.xlsx"
urllib.request.urlretrieve(RAW_URL,raw_path)
raw=pd.read_excel(raw_path)

BASE25=[
    "Entry set thickness","width","Entry actual thickness",
    "S1 rolling forces","S2 rolling forces","S3rolling forces",
    "S1 bending force","S2 bending force","S3 bending force","S4 bending force",
    "S1 rolling speed","S2 rolling speed","S3 rolling speed","S4 rolling speed",
    "S1 back tension","S2 back tension","S3 back tension","S4 back tension",
    "S1 front tension","S2 front tension","S3 front tension","S4 front tension",
    "S5 bending force","S5 rolling speed","S5 back tension",
]
PLUS26=BASE25[:6]+["S4 rolling forces"]+BASE25[6:]
TARGET="S5 rolling forces"
SPEC_ORDER=["1.8|0.181|818","2.75|0.282|794","2.75|0.282|919","3.5|0.916|920","3.5|1.022|1250","3|0.333|853","3|0.352|1000","3|0.461|926"]

# Recover the three S5 fields missing from the cohort CSV by exact row alignment to source workbook.
best=None
for off in range(-4,5):
    pos=df.source_excel_row.astype(int).to_numpy()+off
    if pos.min()<0 or pos.max()>=len(raw): continue
    cand=raw.iloc[pos].reset_index(drop=True)
    cols=["Entry set thickness","width","Entry actual thickness","S1 rolling forces","S2 rolling forces","S3rolling forces","S4 rolling forces",TARGET]
    score=max(float(np.max(np.abs(pd.to_numeric(df[c]).to_numpy(float)-pd.to_numeric(cand[c]).to_numpy(float)))) for c in cols)
    if best is None or score<best[0]: best=(score,off,cand)
if best is None or best[0]>1e-8: raise RuntimeError(best[:2] if best else None)
cand=best[2]
for c in ["S5 bending force","S5 rolling speed","S5 back tension"]:
    df[c]=pd.to_numeric(cand[c],errors="raise").to_numpy(float)

def fold_indices():
    out=[[] for _ in range(4)]
    for s in SPEC_ORDER:
        idx=df.index[df.spec_key.astype(str)==s].to_numpy()
        parts=np.array_split(idx,4)
        for i,p in enumerate(parts): out[i].extend(p.tolist())
    return [np.array(v,dtype=int) for v in out]

def met(y,p):
    return {
      "rmse":float(mean_squared_error(y,p)**0.5),
      "mae":float(mean_absolute_error(y,p)),
      "r2":float(r2_score(y,p))
    }

# Build fold representations once. Theta optimization is independent of alpha/gamma/C.
def build_fold(va, mode):
    tr=np.setdiff1d(df.index.to_numpy(),va)
    X25=df.loc[tr,BASE25].to_numpy(float)
    X26=df.loc[tr,PLUS26].to_numpy(float)
    y=df.loc[tr,TARGET].to_numpy(float)
    yva=df.loc[va,TARGET].to_numpy(float)

    xs=StandardScaler().fit(df.loc[tr,PLUS26])
    Xtr=xs.transform(df.loc[tr,PLUS26])
    Xva=xs.transform(df.loc[va,PLUS26])
    dtr=dk._squared_distances(Xtr,Xtr)
    dva=dk._squared_distances(Xva,Xtr)

    if mode=="reselect_q":
        sel26=dk._select_quantum_features(X26,y,5,20250621)
    elif mode=="q25_locked":
        sel25=dk._select_quantum_features(X25,y,5,20250621)
        names=[BASE25[i] for i in sel25]
        sel26=[PLUS26.index(n) for n in names]
    else:
        raise ValueError(mode)

    qsc=MinMaxScaler((0.0,np.pi)).fit(X26[:,sel26])
    qtr=qsc.transform(X26[:,sel26])*0.4
    qva=qsc.transform(df.loc[va,PLUS26].to_numpy(float)[:,sel26])*0.4

    ys=StandardScaler().fit(y[:,None])
    ytr_s=ys.transform(y[:,None]).ravel()

    # theta optimization uses the frozen C=100 rule from the original model;
    # we then tune the downstream SVR C separately.
    helper=dk.DKQKARV5S2()
    theta=helper._optimize_theta(qtr,ytr_s)
    kq_tr=dk._quantum_kernel(qtr,qtr,theta)
    kq_va=dk._quantum_kernel(qva,qtr,theta)

    return {
      "tr":tr,"va":va,"yva":yva,"ys":ys,"ytr_s":ytr_s,
      "dtr":dtr,"dva":dva,"kq_tr":kq_tr,"kq_va":kq_va,
      "qnames":[PLUS26[i] for i in sel26],"theta":theta.tolist()
    }

ALPHAS=[0.0,0.025,0.05,0.075,0.10,0.15,0.20]
GAMMAS=[0.003,0.005,0.0075,0.01,0.015,0.02,0.03]
CS=[30.0,100.0,300.0]

folds=fold_indices()
all_results=[]
mode_summaries={}
best_by_mode={}

for mode in ["reselect_q","q25_locked"]:
    reps=[build_fold(va,mode) for va in folds]
    for alpha in ALPHAS:
      for gamma in GAMMAS:
        for C in CS:
          fold_ms=[]
          for fi,rep in enumerate(reps,1):
            kr_tr=np.exp(-gamma*rep["dtr"])
            kr_va=np.exp(-gamma*rep["dva"])
            ktr=alpha*rep["kq_tr"]+(1-alpha)*kr_tr
            kva=alpha*rep["kq_va"]+(1-alpha)*kr_va
            reg=SVR(kernel="precomputed",C=C,epsilon=0.01,max_iter=-1,tol=1e-3)
            reg.fit(ktr,rep["ytr_s"])
            ps=reg.predict(kva)
            p=rep["ys"].inverse_transform(ps[:,None]).ravel()
            m=met(rep["yva"],p)
            fold_ms.append(m)
          mean={k:float(np.mean([m[k] for m in fold_ms])) for k in ("rmse","mae","r2")}
          std={k:float(np.std([m[k] for m in fold_ms],ddof=1)) for k in ("rmse","mae","r2")}
          row={"mode":mode,"alpha":alpha,"gamma":gamma,"C":C,
               **{f"mean_{k}":v for k,v in mean.items()},
               **{f"std_{k}":v for k,v in std.items()}}
          all_results.append(row)

    candidates=[r for r in all_results if r["mode"]==mode]
    best=min(candidates,key=lambda r:(r["mean_rmse"],r["std_rmse"],r["mean_mae"]))
    best_by_mode[mode]=best

    # Re-evaluate the best setting and print per-fold details.
    details=[]
    for fi,rep in enumerate(reps,1):
      a,g,C=best["alpha"],best["gamma"],best["C"]
      kr_tr=np.exp(-g*rep["dtr"]); kr_va=np.exp(-g*rep["dva"])
      ktr=a*rep["kq_tr"]+(1-a)*kr_tr
      kva=a*rep["kq_va"]+(1-a)*kr_va
      reg=SVR(kernel="precomputed",C=C,epsilon=0.01,max_iter=-1,tol=1e-3)
      reg.fit(ktr,rep["ytr_s"])
      p=rep["ys"].inverse_transform(reg.predict(kva)[:,None]).ravel()
      details.append({"fold":fi,**met(rep["yva"],p),"q_features":" | ".join(rep["qnames"])})
    mode_summaries[mode]=details

# Sanity-check chosen best configuration on LOSO, without further retuning.
def loso_eval(mode,best):
    rows=[]
    for spec in SPEC_ORDER:
      va=df.index[df.spec_key.astype(str)==spec].to_numpy()
      rep=build_fold(va,mode)
      a,g,C=best["alpha"],best["gamma"],best["C"]
      kr_tr=np.exp(-g*rep["dtr"]); kr_va=np.exp(-g*rep["dva"])
      ktr=a*rep["kq_tr"]+(1-a)*kr_tr
      kva=a*rep["kq_va"]+(1-a)*kr_va
      reg=SVR(kernel="precomputed",C=C,epsilon=0.01,max_iter=-1,tol=1e-3)
      reg.fit(ktr,rep["ytr_s"])
      p=rep["ys"].inverse_transform(reg.predict(kva)[:,None]).ravel()
      rows.append({"spec":spec,**met(rep["yva"],p)})
    macro={k:float(np.mean([r[k] for r in rows])) for k in ("rmse","mae","r2")}
    return rows,macro

loso={}
for mode,best in best_by_mode.items():
    rows,macro=loso_eval(mode,best)
    loso[mode]={"macro":macro,"rows":rows}

pd.DataFrame(all_results).sort_values(["mode","mean_rmse"]).to_csv(HERE/"tune_26d_grid.csv",index=False)
with (HERE/"tune_26d_summary.json").open("w",encoding="utf-8") as f:
    json.dump({"best":best_by_mode,"fourfold_details":mode_summaries,"loso":loso},f,ensure_ascii=False,indent=2)

print("===BEST===")
print(json.dumps(best_by_mode,ensure_ascii=False,indent=2))
print("===FOURFOLD_DETAILS===")
print(json.dumps(mode_summaries,ensure_ascii=False,indent=2))
print("===LOSO===")
print(json.dumps(loso,ensure_ascii=False,indent=2))
