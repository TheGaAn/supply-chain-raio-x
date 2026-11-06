#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

IMG=localhost:5000/ada/pagamentos:v1

docker rm -f registry >/dev/null 2>&1 || true
docker run -d --name registry -p 5000:5000 registry:2 >/dev/null
sleep 2

docker build -t "$IMG" app
docker push "$IMG"

DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "$IMG" | cut -d@ -f2)
echo "imagem publicada: $IMG@$DIGEST"
