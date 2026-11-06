#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== testes =="
opa test policy/supplychain.rego policy/supplychain_test.rego -v

echo
echo "== gate: imagem aprovada =="
opa eval -f pretty -d policy/supplychain.rego -i policy/inputs/aprovada.json 'data.supplychain.allow'

echo
echo "== gate: root =="
opa eval -f pretty -d policy/supplychain.rego -i policy/inputs/root.json 'data.supplychain.deny'

echo
echo "== gate: registry externo =="
opa eval -f pretty -d policy/supplychain.rego -i policy/inputs/dockerhub.json 'data.supplychain.deny'
