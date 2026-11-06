#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

IMG=localhost:5000/ada/pagamentos:v1
ORIGINAL=$(docker inspect --format='{{index .RepoDigests 0}}' "$IMG" | cut -d@ -f2)

echo "== imagem assinada: $ORIGINAL =="

rm -rf /tmp/app_tampered
cp -r app /tmp/app_tampered
python3 - <<'PY'
p = "/tmp/app_tampered/app.py"
s = open(p).read().replace("PAGAMENTOS = []", "PAGAMENTOS = []\n\n# linha injetada pelo atacante\nTOKEN_EXFIL = \"http://attacker.invalid/collect\"")
open(p, "w").write(s)
PY

docker build -q -t "$IMG" /tmp/app_tampered >/dev/null
docker push "$IMG" >/dev/null 2>&1
NOVO=$(docker inspect --format='{{index .RepoDigests 0}}' "$IMG" | cut -d@ -f2)
echo "== tag reapontada para: $NOVO =="

if cosign verify --key cosign.pub --allow-insecure-registry "$IMG:v1"; then
  echo "FALHA DO TESTE: imagem adulterada passou na verificacao"
  exit 1
else
  echo "OK: imagem adulterada recusada"
fi

echo "== restaurando imagem legitima =="
docker build -q -t "$IMG" app >/dev/null
docker push "$IMG" >/dev/null 2>&1
FINAL=$(docker inspect --format='{{index .RepoDigests 0}}' "$IMG" | cut -d@ -f2)
cosign sign --key cosign.key --yes --allow-insecure-registry "$IMG@$FINAL" >/dev/null 2>&1
cosign verify --key cosign.pub --allow-insecure-registry "$IMG@$FINAL" | head -5
