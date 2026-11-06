#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

IMG=localhost:5000/ada/pagamentos:v1
DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$IMG" | cut -d@ -f2)

if [ ! -f cosign.key ]; then
  echo "gerando par de chaves (senha em COSIGN_PASSWORD)"
  cosign generate-key-pair
fi

cosign sign --key cosign.key --yes --allow-insecure-registry "$IMG@$DIGEST"
cosign verify --key cosign.pub --allow-insecure-registry "$IMG@$DIGEST"
