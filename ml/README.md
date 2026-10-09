# ml

Treino, calibração conformal e métricas do Retinova.

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
pytest
```

## Módulos (`src/retinova/`)

- `config.py`: classes de risco e mapeamento ICDR para risco.
- `conformal.py`: calibração e conjuntos de predição (split conformal).
- `metrics.py`: sensibilidade, especificidade e cobertura.

## Próximos passos

1. Baixar a base (credenciada) para `ml/data/` (ignorado pelo git).
2. `scripts/train.py`: treinar o classificador e salvar probabilidades de validação/calibração.
3. Calibrar com `conformal.calibrate` e exportar `qhat` junto com o modelo TFLite.
