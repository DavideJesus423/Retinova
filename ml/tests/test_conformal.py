import sys
from pathlib import Path

import numpy as np
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

from retinova import conformal, metrics  # noqa: E402
from retinova.config import icdr_to_risk  # noqa: E402


def _synthetic(n, rng):
    labels = rng.integers(0, 3, size=n)
    logits = rng.normal(size=(n, 3))
    logits[np.arange(n), labels] += 2.0
    e = np.exp(logits - logits.max(axis=1, keepdims=True))
    return e / e.sum(axis=1, keepdims=True), labels


def test_coverage_is_at_least_target():
    rng = np.random.default_rng(0)
    pc, yc = _synthetic(2000, rng)
    pt, yt = _synthetic(5000, rng)
    qhat = conformal.calibrate(pc, yc, alpha=0.1)
    cov = metrics.coverage(conformal.predict_sets(pt, qhat), yt)
    assert cov >= 0.88  # 0.9 com folga estatística


def test_decide_abstains_when_ambiguous():
    probs = np.array([[0.98, 0.01, 0.01], [0.45, 0.45, 0.10]])
    qhat = 0.5  # conjunto = {p >= 0.5}
    out = conformal.decide(probs, qhat)
    assert out[0] == 0
    assert out[1] == -1  # nenhum acima de 0.5 -> conjunto vazio -> "não sei"


def test_decide_abstains_when_two_classes():
    probs = np.array([[0.55, 0.40, 0.05]])
    out = conformal.decide(probs, qhat=0.65)  # limiar 0.35 -> duas classes
    assert out[0] == -1


def test_calibrate_validates_input():
    with pytest.raises(ValueError):
        conformal.calibrate(np.zeros((0, 3)), np.zeros(0), 0.1)
    with pytest.raises(ValueError):
        conformal.calibrate(np.ones((2, 3)) / 3, np.array([0, 1]), 1.5)


def test_icdr_mapping():
    assert [icdr_to_risk(i) for i in range(5)] == [0, 1, 1, 2, 2]
    with pytest.raises(ValueError):
        icdr_to_risk(7)


def test_sensitivity_ignores_abstentions():
    y_true = np.array([0, 1, 2, 2])
    y_pred = np.array([0, 1, -1, 2])
    sens, spec = metrics.sensitivity_specificity(y_true, y_pred)
    assert sens == 1.0 and spec == 1.0
