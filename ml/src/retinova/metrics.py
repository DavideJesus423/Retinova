"""Métricas de triagem e de conformal prediction."""

from __future__ import annotations

import numpy as np


def coverage(sets: np.ndarray, labels: np.ndarray) -> float:
    """Fração de amostras cuja classe verdadeira está no conjunto de predição."""
    labels = np.asarray(labels, dtype=int)
    return float(np.mean(sets[np.arange(len(labels)), labels]))


def abstention_rate(decisions: np.ndarray) -> float:
    """Fração de casos em que o modelo respondeu "não sei" (-1)."""
    return float(np.mean(np.asarray(decisions) == -1))


def sensitivity_specificity(y_true: np.ndarray, y_pred: np.ndarray, positive_min: int = 1):
    """Sensibilidade e especificidade para "doença" = classe >= positive_min.

    Ignora (não conta) casos com y_pred == -1; reporte a taxa de abstenção junto.
    """
    y_true = np.asarray(y_true)
    y_pred = np.asarray(y_pred)
    keep = y_pred != -1
    t = y_true[keep] >= positive_min
    p = y_pred[keep] >= positive_min
    tp = np.sum(t & p)
    fn = np.sum(t & ~p)
    tn = np.sum(~t & ~p)
    fp = np.sum(~t & p)
    sens = float(tp / (tp + fn)) if (tp + fn) else float("nan")
    spec = float(tn / (tn + fp)) if (tn + fp) else float("nan")
    return sens, spec
