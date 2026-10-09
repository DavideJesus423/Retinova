# Retinova

Triagem de retinopatia diabética por celular, com IA que sabe quando não tem certeza.

> **Status:** protótipo em desenvolvimento (Campus Mobile, 15ª edição, categoria Saúde e Tecnologias Assistivas).
> **Não é um dispositivo médico e não faz diagnóstico.** É uma ferramenta de apoio à triagem. Qualquer uso clínico exigiria validação e registro (Anvisa).

## O problema

A retinopatia diabética é uma das principais causas de cegueira evitável. Fora dos grandes centros, o SUS tem poucos oftalmologistas, e o paciente diabético costuma descobrir a doença tarde, quando a visão já foi perdida.

## A solução

1. O agente de saúde ou enfermeiro da unidade fotografa a retina com o celular e uma lente adaptadora de baixo custo (impressa em 3D).
2. Uma IA roda **no próprio aparelho, sem internet**, e classifica o risco: **ok / acompanhar / encaminhar urgente**.
3. Quando a IA **não tem certeza** ("não sei"), o caso é enviado por sincronização (dados móveis ou SMS) para um oftalmologista parceiro.

## Diferenciais

- IA offline no aparelho (funciona em unidade sem internet).
- Incerteza calibrada: conformal prediction com cobertura estatística definida, em vez de uma probabilidade "chutada".
- Hardware de baixo custo (lente impressa em 3D).
- Só os casos incertos sobem para o especialista, o que poupa a fila.

## Estrutura do repositório

```
app/        App Flutter (captura, classificação no aparelho, fila de sincronização)
ml/         Treino, calibração conformal e métricas (Python)
docs/       Arquitetura, limitações e plano
scripts/    Utilitários (ex.: publicar o repositório)
```

## Como rodar

### ML (Python 3.10+)

```bash
cd ml
python -m venv .venv && source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
pytest
```

### App (Flutter 3.22+)

```bash
cd app
flutter create . --platforms=android --project-name retinova   # gera a pasta android/ (só na 1ª vez)
flutter pub get
flutter test
flutter run
```

Mais detalhes em [`app/README.md`](app/README.md) e [`ml/README.md`](ml/README.md).

## Dados

O treino usa bases públicas de retinografia. **Nenhum dado de paciente ou da base é versionado neste repositório** (veja `.gitignore`). O acesso à BRSET exige credenciamento no PhysioNet e aceite do termo de uso; cada pessoa da equipe usa sua própria cópia local.

## Limitações conhecidas

Veja [`docs/LIMITACOES.md`](docs/LIMITACOES.md). Resumo: as imagens de treino vêm de câmeras de fundo de olho, não de celular com lente adaptadora, então o desempenho em campo precisa ser medido em imagens de celular antes de qualquer conclusão.

## Equipe

Projeto de estudantes para o Campus Mobile (Instituto Claro). Contribuições: veja os issues.

## Licença

[MIT](LICENSE)
