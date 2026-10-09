#!/usr/bin/env bash
# Cria o repositório PÚBLICO "retinova" no seu GitHub e envia tudo.
# Uso (na pasta do projeto):  bash scripts/publicar_no_github.sh
set -e

NOME="retinova"
DESC="Triagem de retinopatia diabética por celular, com IA offline que sabe quando não tem certeza."

if ! command -v gh >/dev/null 2>&1; then
  echo "Instale o GitHub CLI: https://cli.github.com  (depois rode 'gh auth login')"
  echo "Alternativa sem gh: crie um repo público vazio '$NOME' em github.com/new e rode:"
  echo "  git remote add origin https://github.com/SEU_USUARIO/$NOME.git"
  echo "  git push -u origin main"
  exit 1
fi

gh auth status >/dev/null 2>&1 || gh auth login

gh repo create "$NOME" --public --description "$DESC" --source=. --remote=origin --push
echo "Pronto! Repositório criado e enviado."
