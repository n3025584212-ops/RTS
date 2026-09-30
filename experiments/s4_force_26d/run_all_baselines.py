from __future__ import annotations
import json, urllib.request
from pathlib import Path
import numpy as np, pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
from sklearn.pipeline import make_pipeline
from sklearn.ensemble import ExtraTreesRegressor, GradientBoostingRegressor, RandomForestRegressor
from sklearn.neural_network import MLPRegressor
from sklearn.linear_model import ElasticNet
try:
    from xgboost import XGBRegressor
except Exception:
    XGBRegressor=None

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

# align source rows to raw and append missing S5 features
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

def folds():
    out=[[] for _ in range(4)]
    for s in SPEC_ORDER:
        idx=df.index[df.spec_key.astype(str)==s].to_numpy()
        parts=np.array_split(idx,4)
        for i,p in enumerate(parts): out[i].extend(p.tolist())
    return [np.array(v,dtype=int) for v in out]

def met(y,p):
    return dict(rmse=float(mean_squared_error(y,p)**0.5),mae=float(mean_absolute_error(y,p)),r2=float(r2_score(y,p)))

def models():
    d={
      "ExtraTrees": ExtraTreesRegressor(n_estimators=500,random_state=20250621,n_jobs=-1),
      "GradientBoosting": GradientBoostingRegressor(random_state=20250621),
      "RandomForest": RandomForestRegressor(n_estimators=500,random_state=20250621,n_jobs=-1),
      "ElasticNet": make_pipeline(StandardScaler(),ElasticNet(alpha=1.0,l1_ratio=0.5,random_state=20250621,max_iter=10000)),
      "MLP": make_pipeline(StandardScaler(),MLPRegressor(hidden_layer_sizes=(64,32),random_state=20250621,max_iter=5000,early_stopping=True)),
    }
    if XGBRegressor is not None:
      d["XGBoost"]=XGBRegressor(n_estimators=500,max_depth=4,learning_rate=0.03,subsample=0.9,colsample_bytree=0.9,random_state=20250621,n_jobs=2,objective="reg:squarederror")
    return d

rows=[]
for feats,dim in [(BASE25,25),(PLUS26,26)]:
    for name,proto in models().items():
        vals=[]
        for fi,va in enumerate(folds(),1):
            tr=np.setdiff1d(df.index.to_numpy(),va)
            # clone via sklearn
            from sklearn.base import clone
            m=clone(proto)
            m.fit(df.loc[tr,feats],df.loc[tr,TARGET])
            pred=m.predict(df.loc[va,feats]); y=df.loc[va,TARGET].to_numpy(float)
            mm=met(y,pred); vals.append(mm)
            rows.append({"model":name,"dim":dim,"fold":fi,**mm})
        rows.append({"model":name,"dim":dim,"fold":"mean",
                     "rmse":float(np.mean([v["rmse"] for v in vals])),
                     "mae":float(np.mean([v["mae"] for v in vals])),
                     "r2":float(np.mean([v["r2"] for v in vals]))})
out=pd.DataFrame(rows)
print(out.to_csv(index=False))
summary=out[out.fold.astype(str)=="mean"].pivot(index="model",columns="dim",values=["rmse","mae","r2"])
print("===SUMMARY===")
print(summary.to_string())
