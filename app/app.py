from flask import Flask, jsonify, request

app = Flask(__name__)

PAGAMENTOS = []

@app.get("/health")
def health():
    return jsonify(status="ok")

@app.post("/pagamentos")
def criar_pagamento():
    dado = request.get_json(silent=True) or {}
    valor = dado.get("valor")
    if not isinstance(valor, (int, float)) or valor <= 0:
        return jsonify(erro="valor invalido"), 400
    PAGAMENTOS.append({"id": len(PAGAMENTOS) + 1, "valor": valor})
    return jsonify(PAGAMENTOS[-1]), 201

@app.get("/pagamentos")
def listar():
    return jsonify(PAGAMENTOS)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
