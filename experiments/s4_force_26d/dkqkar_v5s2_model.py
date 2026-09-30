"""Deployable DK-QKAR-V5S2 dual-kernel predictor for S5 rolling force.

This implementation preserves the frozen Stage-2 model structure:
    K_DK = 0.10 * K_Q + 0.90 * K_R
with C=100, epsilon=0.01, gamma=0.01, lambda=0.4 and a 5D quantum map.

For deployment, ``fit`` may refit the 5 selected quantum inputs and theta on an
explicitly supplied training set. Benchmark metrics from the frozen study must
not be presented as a fresh evaluation of that deployment refit.
"""
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Mapping, Sequence
import math
import pickle

import numpy as np
import pandas as pd
from sklearn.feature_selection import mutual_info_regression
from sklearn.preprocessing import MinMaxScaler, StandardScaler
from sklearn.svm import SVR

TARGET = "S5 rolling forces"

FEATURES = [
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


def _pair_indices(n_qubits: int, q: int) -> tuple[np.ndarray, np.ndarray]:
    dim = 1 << n_qubits
    i0 = np.asarray([x for x in range(dim) if ((x >> q) & 1) == 0])
    return i0, i0 | (1 << q)


def _gate(
    states: np.ndarray,
    q: int,
    a: complex | np.ndarray,
    b: complex | np.ndarray,
    c: complex | np.ndarray,
    d: complex | np.ndarray,
    pairs: list[tuple[np.ndarray, np.ndarray]],
) -> None:
    i0, i1 = pairs[q]
    v0 = states[:, i0].copy()
    v1 = states[:, i1].copy()

    def bc(z: complex | np.ndarray) -> complex | np.ndarray:
        z = np.asarray(z)
        return z if z.ndim == 0 else z[:, None]

    states[:, i0] = bc(a) * v0 + bc(b) * v1
    states[:, i1] = bc(c) * v0 + bc(d) * v1


def _states(X: np.ndarray, theta: np.ndarray) -> np.ndarray:
    X = np.asarray(X, dtype=float)
    n_samples, n_qubits = X.shape
    if n_qubits != len(theta):
        raise ValueError("Quantum feature dimension and theta length differ.")
    dim = 1 << n_qubits
    states = np.zeros((n_samples, dim), dtype=complex)
    states[:, 0] = 1.0
    pairs = [_pair_indices(n_qubits, q) for q in range(n_qubits)]

    for q in range(n_qubits):
        co = math.cos(theta[q] / 2.0)
        ss = -1j * math.sin(theta[q] / 2.0)
        _gate(states, q, co, ss, ss, co, pairs)

    h = 1.0 / math.sqrt(2.0)
    for q in range(n_qubits):
        _gate(states, q, h, h, h, -h, pairs)
        x = X[:, q]
        _gate(states, q, np.exp(-0.5j * x), 0, 0, np.exp(0.5j * x), pairs)
        co = math.cos(math.pi / 8.0)
        si = math.sin(math.pi / 8.0)
        _gate(states, q, co, -si, si, co, pairs)

    idx = np.arange(dim)
    for q in range(n_qubits - 1):
        perm = idx.copy()
        mask = ((perm >> q) & 1) == 1
        perm[mask] ^= 1 << (q + 1)
        states = states[:, perm]

    for q in range(n_qubits):
        x = X[:, q]
        co = np.cos(x / 2.0)
        ss = -1j * np.sin(x / 2.0)
        _gate(states, q, co, ss, ss, co, pairs)
    return states


def _quantum_kernel(A: np.ndarray, B: np.ndarray, theta: np.ndarray) -> np.ndarray:
    sa = _states(A, theta)
    same_object = A is B
    sb = sa if same_object else _states(B, theta)
    kernel = np.abs(sa @ sb.conj().T) ** 2
    kernel = np.clip(kernel.real, 0.0, 1.0)
    if same_object:
        kernel = (kernel + kernel.T) / 2.0
        np.fill_diagonal(kernel, 1.0)
    return kernel


def _squared_distances(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    return np.maximum(
        (A * A).sum(axis=1)[:, None]
        + (B * B).sum(axis=1)[None, :]
        - 2.0 * A @ B.T,
        0.0,
    )


def _select_quantum_features(
    X: np.ndarray, y: np.ndarray, k: int, seed: int
) -> list[int]:
    relevance = mutual_info_regression(X, y, random_state=seed)
    corr = np.nan_to_num(np.corrcoef(X, rowvar=False), nan=0.0)
    selected: list[int] = []
    candidates = set(range(X.shape[1]))
    while len(selected) < k:
        best = max(
            sorted(candidates),
            key=lambda i: float(
                relevance[i]
                - (0.0 if not selected else np.mean(np.abs(corr[i, selected])))
            ),
        )
        selected.append(best)
        candidates.remove(best)
    return selected


@dataclass
class DKQKARV5S2:
    C: float = 100.0
    epsilon: float = 0.01
    gamma: float = 0.01
    lambda_scale: float = 0.4
    alpha: float = 0.10
    quantum_dim: int = 5
    selection_seed: int = 20250621
    theta_steps: tuple[float, ...] = (0.06, 0.03, 0.015)

    def __post_init__(self) -> None:
        self.x_scaler = StandardScaler()
        self.q_scaler = MinMaxScaler((0.0, np.pi))
        self.y_scaler = StandardScaler()
        self.selected_feature_indices: list[int] = []
        self.selected_features: list[str] = []
        self.theta = np.zeros(self.quantum_dim, dtype=float)
        self.train_x_scaled: np.ndarray | None = None
        self.train_q_scaled: np.ndarray | None = None
        self.regressor: SVR | None = None
        self.is_fitted = False

    @staticmethod
    def _as_frame(
        X: pd.DataFrame | Sequence[Sequence[float]] | Mapping[str, float]
    ) -> pd.DataFrame:
        if isinstance(X, Mapping):
            X = pd.DataFrame([X])
        elif not isinstance(X, pd.DataFrame):
            X = pd.DataFrame(X, columns=FEATURES)
        missing = [column for column in FEATURES if column not in X.columns]
        if missing:
            raise ValueError(f"Missing input features: {missing}")
        frame = X.loc[:, FEATURES].apply(pd.to_numeric, errors="raise").astype(float)
        if not np.isfinite(frame.to_numpy()).all():
            raise ValueError("Inputs contain NaN or infinite values.")
        return frame

    def _qka_loss(self, kernel: np.ndarray, y_scaled: np.ndarray) -> float:
        reg = SVR(
            kernel="precomputed", C=self.C, epsilon=self.epsilon,
            max_iter=-1, tol=1e-3,
        ).fit(kernel, y_scaled)
        beta = np.zeros(len(y_scaled), dtype=float)
        beta[reg.support_] = reg.dual_coef_.ravel()
        return float(
            -0.5 * beta @ kernel @ beta
            - self.epsilon * np.abs(beta).sum()
            + y_scaled @ beta
        )

    def _optimize_theta(self, A: np.ndarray, y_scaled: np.ndarray) -> np.ndarray:
        theta = np.zeros(A.shape[1], dtype=float)
        best_value = self._qka_loss(_quantum_kernel(A, A, theta), y_scaled)
        for step in self.theta_steps:
            for j in range(len(theta)):
                base = theta.copy()
                best = (best_value, theta.copy())
                for sign in (-1.0, 1.0):
                    candidate = base.copy()
                    candidate[j] = ((candidate[j] + sign * step + np.pi) % (2 * np.pi)) - np.pi
                    value = self._qka_loss(_quantum_kernel(A, A, candidate), y_scaled)
                    if value < best[0] - 1e-12:
                        best = (value, candidate)
                if best[0] < best_value - 1e-12:
                    best_value, theta = best
        return theta

    def fit(
        self, X: pd.DataFrame | Sequence[Sequence[float]], y: Iterable[float]
    ) -> "DKQKARV5S2":
        frame = self._as_frame(X)
        target = np.asarray(list(y), dtype=float)
        if len(frame) != len(target):
            raise ValueError("X and y have different sample counts.")
        if not np.isfinite(target).all():
            raise ValueError("Target contains NaN or infinite values.")
        if len(frame) < 10:
            raise ValueError("Too few samples for a stable DK-QKAR fit.")

        raw = frame.to_numpy(dtype=float)
        self.selected_feature_indices = _select_quantum_features(
            raw, target, self.quantum_dim, self.selection_seed
        )
        self.selected_features = [FEATURES[i] for i in self.selected_feature_indices]

        self.train_x_scaled = self.x_scaler.fit_transform(frame)
        selected_raw = raw[:, self.selected_feature_indices]
        self.train_q_scaled = self.q_scaler.fit_transform(selected_raw) * self.lambda_scale

        y_scaled = self.y_scaler.fit_transform(target[:, None]).ravel()
        self.theta = self._optimize_theta(self.train_q_scaled, y_scaled)

        kr = np.exp(-self.gamma * _squared_distances(self.train_x_scaled, self.train_x_scaled))
        kq = _quantum_kernel(self.train_q_scaled, self.train_q_scaled, self.theta)
        kdk = self.alpha * kq + (1.0 - self.alpha) * kr
        self.regressor = SVR(
            kernel="precomputed", C=self.C, epsilon=self.epsilon,
            max_iter=-1, tol=1e-3,
        ).fit(kdk, y_scaled)
        self.is_fitted = True
        return self

    def _cross_kernel(self, frame: pd.DataFrame) -> np.ndarray:
        if not self.is_fitted or self.regressor is None:
            raise RuntimeError("Model is not fitted. Call fit() or load() first.")
        assert self.train_x_scaled is not None and self.train_q_scaled is not None
        raw = frame.to_numpy(dtype=float)
        x_scaled = self.x_scaler.transform(frame)
        q_scaled = self.q_scaler.transform(raw[:, self.selected_feature_indices]) * self.lambda_scale
        kr = np.exp(-self.gamma * _squared_distances(x_scaled, self.train_x_scaled))
        kq = _quantum_kernel(q_scaled, self.train_q_scaled, self.theta)
        return self.alpha * kq + (1.0 - self.alpha) * kr

    def predict(
        self, X: pd.DataFrame | Sequence[Sequence[float]] | Mapping[str, float]
    ) -> np.ndarray:
        frame = self._as_frame(X)
        kernel = self._cross_kernel(frame)
        assert self.regressor is not None
        pred_scaled = self.regressor.predict(kernel)
        return self.y_scaler.inverse_transform(pred_scaled[:, None]).ravel()

    def predict_one(self, process_parameters: Mapping[str, float]) -> float:
        return float(self.predict(process_parameters)[0])

    def save(self, path: str | Path) -> None:
        if not self.is_fitted:
            raise RuntimeError("Fit the model before saving it.")
        path = Path(path)
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("wb") as handle:
            pickle.dump(self, handle, protocol=pickle.HIGHEST_PROTOCOL)

    @staticmethod
    def load(path: str | Path) -> "DKQKARV5S2":
        with Path(path).open("rb") as handle:
            model = pickle.load(handle)
        if not isinstance(model, DKQKARV5S2):
            raise TypeError("File does not contain a DKQKARV5S2 model.")
        return model

    def model_card(self) -> dict[str, object]:
        return {
            "model_name": "DK-QKAR-V5S2",
            "target": TARGET,
            "input_dim": len(FEATURES),
            "quantum_dim": self.quantum_dim,
            "selected_features": list(self.selected_features),
            "theta": [float(v) for v in self.theta],
            "parameters": {
                "C": self.C,
                "epsilon": self.epsilon,
                "gamma": self.gamma,
                "lambda": self.lambda_scale,
                "alpha": self.alpha,
                "dual_kernel": f"{self.alpha:.2f}*K_Q + {1.0-self.alpha:.2f}*K_R",
            },
        }