# Arquitetura

```
 [Foto da retina]  ->  [Pré-processamento]  ->  [Modelo TFLite no aparelho]
                                                        |
                                              probabilidades por classe
                                                        |
                                           [Conformal: conjunto de predição]
                                              /                    \
                                  1 classe só                  0 ou 2+ classes
                                       |                            |
                         ok / acompanhar / encaminhar          "não sei"
                                                                    |
                                                    [Fila local] -> [Sync: dados ou SMS]
                                                                    |
                                                          Oftalmologista parceiro
```

## Classes de risco

Mapeadas a partir da escala ICDR (0 a 4) da base de treino:

| ICDR | Risco |
|------|-------|
| 0 | ok |
| 1, 2 | acompanhar |
| 3, 4 | encaminhar urgente |

(A faixa exata deve ser validada pelo colega da medicina.)

## Regra de decisão

Conformal prediction (split, score = 1 - p da classe verdadeira). Com o limiar `qhat` calibrado para erro alvo `alpha`, o conjunto de predição é `{k : p_k >= 1 - qhat}`. Se o conjunto tem exatamente uma classe, o app mostra o risco; caso contrário, mostra "não sei" e enfileira o caso.

A mesma regra existe em `ml/src/retinova/conformal.py` (treino/avaliação) e `app/lib/core/decision.dart` (aparelho). Os testes dos dois lados usam os mesmos casos para manter o comportamento idêntico.

## Sincronização

- A fila é local e persistente (a implementar com sqflite).
- Envio por dados móveis quando houver conexão; por SMS como alternativa (mensagem curta, sem dados identificáveis do paciente, para respeitar a LGPD).
- Formato da mensagem: `RETINOVA|<id-do-caso>|<risco-mais-provável>|<p_ok>,<p_acomp>,<p_urg>`.

## Pendências técnicas

- Exportar o modelo para TFLite e integrar ao app (Dia 3 a 4).
- Persistência da fila (sqflite).
- Simulação de aprendizado federado (opcional, só se sobrar tempo).
