"""Classes de risco e mapeamento a partir da escala ICDR (0 a 4)."""

RISK_CLASSES = ("ok", "acompanhar", "encaminhar_urgente")

# ICDR 0 -> ok; 1-2 -> acompanhar; 3-4 -> encaminhar urgente.
# Faixas a validar com o colega da medicina.
ICDR_TO_RISK = {0: 0, 1: 1, 2: 1, 3: 2, 4: 2}


def icdr_to_risk(icdr: int) -> int:
    """Converte um grau ICDR (0..4) no índice da classe de risco."""
    try:
        return ICDR_TO_RISK[int(icdr)]
    except KeyError as exc:
        raise ValueError(f"Grau ICDR inválido: {icdr!r} (esperado 0..4)") from exc
