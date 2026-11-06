package supplychain

default allow := false

# Só aceita imagem do registry interno, sem root e sem CVE crítica.
allow if {
	input.image.registry == "localhost:5000"
	not roda_como_root
	not tem_critica
}

roda_como_root if input.image.user == "root"
roda_como_root if input.image.user == ""

tem_critica if {
	some v in input.vulnerabilities
	v.severity == "CRITICAL"
}

deny contains msg if {
	not input.image.registry == "localhost:5000"
	msg := sprintf("registry nao aprovado: %s", [input.image.registry])
}

deny contains msg if {
	roda_como_root
	msg := "container roda como root"
}

deny contains msg if {
	tem_critica
	msg := "imagem tem vulnerabilidade CRITICAL"
}
