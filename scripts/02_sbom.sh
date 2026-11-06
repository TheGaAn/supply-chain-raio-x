#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

IMG=localhost:5000/ada/pagamentos:v1
mkdir -p out

syft "$IMG" -o spdx-json=out/sbom.spdx.json -o cyclonedx-json=out/sbom.cdx.json -q

echo "pacotes no SPDX: $(python3 -c "import json;print(len(json.load(open('out/sbom.spdx.json'))['packages']))")"
ls -lh out/sbom.spdx.json out/sbom.cdx.json
