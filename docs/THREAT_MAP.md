# Mapa de ameaças - onde o atacante entra e o que evidencia

**Ativo:** imagem `localhost:5000/ada/pagamentos:v1` e o pipeline que a produz.

| # | Ponto de entrada | Como o ataque funciona | Controle do curso | O que fica como evidência |
|---|---|---|---|---|
| 1 | Dependência | pacote malicioso ou versão vulnerável entra via `requirements.txt` | SBOM (Syft) + SCA (Trivy) | lista de pacotes e CVE com versão instalada e correção |
| 2 | Build | build server comprometido injeta código na imagem | assinatura Cosign + procedência (SLSA) | assinatura por digest; qualquer rebuild gera outro digest |
| 3 | Registry | imagem é substituída por outra sob a mesma tag | verificação Cosign antes do deploy | `cosign verify` falha com `no signatures found` |
| 4 | Admissão | container sobe como root ou de registry não aprovado | policy Rego (OPA) | `deny` com motivo, avaliado antes do deploy |
| 5 | Distribuição | artefato é trocado depois de publicado | digest imutável + transparência (Rekor) | digest assinado e registro público da assinatura |

## O elo mais fraco

O elo não é a vulnerabilidade em si, é a **confiança na tag**. Tag é um ponteiro móvel: `v1` hoje e `v1` amanhã podem ser imagens diferentes. O controle que fecha isso é endereçar por **digest** e verificar a assinatura antes de qualquer `docker pull` em produção.

## Ligação com um caso real

No **xz-utils (CVE-2024-3094)**, o mantenedor de longa data foi pressionado e o tarball de release passou a incluir um backdoor no build. O código no repositório Git não era o código distribuído. Duas camadas teriam mudado o jogo:

1. **SBOM + procedência:** mostrar que o binário publicado não corresponde ao build esperado.
2. **Assinatura por digest:** impedir que o artefato adulterado fosse aceito mesmo com a tag correta.

O mesmo raciocínio vale para SolarWinds (build comprometido) e Codecov (script de upload alterado): o atacante raramente ataca o código-fonte, ataca o **caminho entre o código e o artefato**.

## Resposta à pergunta de compliance

*Se essa cadeia fosse atacada amanhã, que evidência eu teria para provar o que aconteceu?*

- **O que rodava:** SBOM SPDX/CycloneDX versionado, com nome, versão e licença de cada componente.
- **O que estava vulnerável:** relatório do Trivy em JSON, com CVE, pacote, versão instalada e correção disponível.
- **Quem autorizou:** policy Rego versionada, com teste automatizado e resultado do gate.
- **O que foi publicado:** digest da imagem e assinatura Cosign verificável por qualquer pessoa com a chave pública.
- **Quando mudou:** cada rebuild produz um digest diferente; a verificação falha se a imagem não for a assinada.

A trilha é suficiente para responder às cinco perguntas clássicas de auditoria: o quê, onde, quando, quem e com qual autorização.
