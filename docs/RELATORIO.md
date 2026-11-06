# Relatório do projeto final

## Checklist de avaliação

| Item | Status | Evidência |
|---|---|---|
| Escreveu e testou a policy Rego | feito | `policy/supplychain.rego`, `policy/supplychain_test.rego`, `evidence/01_policy_test.png`, `evidence/02_policy_gate.png` |
| Gerou o SBOM | feito | `out/sbom.spdx.json`, `out/sbom.cdx.json`, `evidence/03_sbom.png` |
| Encontrou e registrou 1 vulnerabilidade real | feito | CVE-2026-31789 (openssl 3.0.14), `out/trivy.json`, `evidence/04_trivy.png` |
| Assinou/verificou com Cosign | feito | `evidence/05_cosign_sign.png`, `evidence/06_cosign_verify.png`, `evidence/07_tamper_detectado.png` |
| Conectou com um caso real de ataque | feito | `docs/THREAT_MAP.md` (xz-utils / SolarWinds) |

## Antes e depois

**Antes:** `python:3.8-slim`, processo como root, `flask==2.0.1` e `requests==2.25.1` fixos, nenhuma assinatura, nenhum inventário. Resultado: 119 vulnerabilidades HIGH/CRITICAL, 9 delas críticas.

**Depois:** a mesma aplicação passa a ter (1) gate de política que recusa root, registry externo e CVE crítica; (2) inventário completo em dois formatos; (3) assinatura vinculada ao digest, com verificação que falha quando a imagem é trocada.

## Achado principal

`CVE-2026-31789` - OpenSSL 3.0.14 em `libssl3` e `openssl`, buffer overflow de heap; correção em 3.0.19-1~deb12u2. É explorável em serviços que expõem TLS e serve como exemplo concreto de dependência transitiva que não aparece no `requirements.txt`.

## Limitações

- A assinatura usa par de chaves local (`cosign.key` fora do repositório), não o modo keyless com OIDC do Sigstore. O fluxo de verificação é o mesmo; keyless apenas troca a âncora de confiança para a identidade OIDC.
- O registry é local (`localhost:5000`), sem TLS. Em produção, a policy exigiria HTTPS e registry autenticado.
- A imagem continua vulnerável de propósito: o objetivo é demonstrar detecção e bloqueio, não corrigir a aplicação.
