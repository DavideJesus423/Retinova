"""Split conformal prediction para classificação.

Score de não conformidade: s = 1 - p(classe verdadeira).
Conjunto de predição: {k : p_k >= 1 - qhat_k}.
qhat pode ser um número (igual para todas as classes) ou um vetor com um qhat
por classe (conformal condicional à classe, como no app).
Se o conjunto não tem exatamente uma classe, o app responde "não sei".
"""

from __future__ import annotations

import math

import numpy as np


def calibrate(probs: np.ndarray, labels: np.ndarray, alpha: float = 0.1) -> float:
    """Calcula o limiar qhat com cobertura >= 1 - alpha (em média).

    probs: (n, k) probabilidades do conjunto de calibração.
    labels: (n,) índices das classes verdadeiras.
    """
    probs = np.asarray(probs, dtype=float)
    labels = np.asarray(labels, dtype=int)
    n = len(labels)
    if n == 0:
        raise ValueError("Conjunto de calibração vazio.")
    if not 0 < alpha < 1:
        raise ValueError("alpha deve estar em (0, 1).")
    scores = 1.0 - probs[np.arange(n), labels]
    rank = math.ceil((n + 1) * (1 - alpha))
    if rank > n:
        # Poucos dados para esse alpha: devolve o máximo (conjuntos conservadores).
        return float(np.max(scores))
    return float(np.sort(scores)[rank - 1])


def predict_sets(probs: np.ndarray, qhat) -> np.ndarray:
    """Máscara booleana (n, k): True se a classe está no conjunto de predição."""
    probs = np.asarray(probs, dtype=float)
    return probs >= (1.0 - np.asarray(qhat, dtype=float))  # escalar ou (k,)


def decide(probs: np.ndarray, qhat) -> np.ndarray:
    """Decisão por amostra: índice da classe, ou -1 para "não sei"."""
    sets = predict_sets(probs, qhat)
    sizes = sets.sum(axis=1)
    top = np.argmax(np.where(sets, probs, -np.inf), axis=1)
    return np.where(sizes == 1, top, -1)
