package supplychain_test

import data.supplychain

ok_image := {"image": {"registry": "localhost:5000", "user": "1001"}, "vulnerabilities": []}

test_imagem_aprovada if {
	supplychain.allow with input as ok_image
}

test_bloqueia_root if {
	nao_permite({"image": {"registry": "localhost:5000", "user": "root"}, "vulnerabilities": []})
	"container roda como root" in supplychain.deny with input as {"image": {"registry": "localhost:5000", "user": "root"}, "vulnerabilities": []}
}

test_bloqueia_registry if {
	nao_permite({"image": {"registry": "docker.io", "user": "1001"}, "vulnerabilities": []})
}

test_bloqueia_critica if {
	nao_permite({"image": {"registry": "localhost:5000", "user": "1001"}, "vulnerabilities": [{"severity": "CRITICAL", "id": "CVE-2024-0001"}]})
}

nao_permite(inp) if {
	not supplychain.allow with input as inp
}
