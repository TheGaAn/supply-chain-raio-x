#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

IMG=localhost:5000/ada/pagamentos:v1
mkdir -p out

trivy image --severity HIGH,CRITICAL "$IMG"
trivy image -q --severity HIGH,CRITICAL -f json -o out/trivy.json "$IMG"

python3 - <<'PY'
import json
d = json.load(open("out/trivy.json"))
v = [x for r in d.get("Results", []) for x in r.get("Vulnerabilities", [])]
c = [x for x in v if x["Severity"] == "CRITICAL"]
print(f"
Total HIGH/CRITICAL: {len(v)} (CRITICAL {len(c)})")
for x in c:
    print(f"  {x['VulnerabilityID']} {x['PkgName']} {x['InstalledVersion']} -> {x.get('FixedVersion','-')}")
PY
