# ==========================================
# Variáveis Globais e Configurações
# ==========================================
SHELL := /bin/bash
BUCKET_NAME=lab-devops-terraform-state-v1
ENDPOINT=http://localhost:4566
TF_CMD=terraform
TF_PLAN_FILE=terraform.tfplan

.PHONY: up bootstrap-full plan-confirm test-confirm bootstrap apply destroy list-db list-s3 stress-test clean-s3-logs test-upload

# ==========================================
# 0. MASTER: Orquestração do Ambiente
# ==========================================
up: bootstrap-full plan-confirm test-confirm

# ==========================================
# 1. BOOTSTRAP: Inicialização do Laboratório
# ==========================================
bootstrap:
	@echo "🔄 Reiniciando containers e volumes..."
	docker-compose down
	docker-compose up -d
	@echo "⏳ Aguardando estabilização dos serviços (30s)..."
	@sleep 30 
	
	@echo "🧹 Limpando metadados locais..."
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
	
	@echo "🚀 Provisionando Backend S3..."
	aws --endpoint-url=$(ENDPOINT) s3 mb s3://$(BUCKET_NAME)
	
	@echo "📦 Inicializando Infraestrutura como Código..."
	$(TF_CMD) init
	
	@echo "🔗 Sincronizando estado do Backend..."
	# CORREÇÃO AQUI: module.s3_bucket_infra em vez de s3_bucket_devops
	$(TF_CMD) import module.s3_bucket_infra.aws_s3_bucket.this $(BUCKET_NAME)
	@echo "✅ Ambiente Docker e IaC prontos!"

# ==========================================
# 2. PROVISIONAMENTO: Ciclo de Vida do Terraform
# ==========================================
bootstrap-full:
	@echo "🚀 Iniciando ciclo de vida da infraestrutura..."
	$(MAKE) bootstrap
	@echo "⏳ Finalizando setup (10s)..."
	@sleep 10

plan-confirm:
	@echo "🔍 Gerando plano de execução..."
	$(TF_CMD) plan -out=$(TF_PLAN_FILE)
	@echo ""
	@echo "⚠️  REVISÃO TÉCNICA: Valide os recursos acima."
	@read -p "🚀 Confirmar deploy da infraestrutura? [y/N]: " ans; \
	if [ "$$ans" = "y" ] || [ "$$ans" = "Y" ]; then \
		echo "⚙️  Aplicando configurações..."; \
		$(TF_CMD) apply $(TF_PLAN_FILE); \
		rm $(TF_PLAN_FILE); \
	else \
		echo "❌ Operação cancelada."; \
		exit 1; \
	fi

destroy:
	$(TF_CMD) destroy -auto-approve
	@echo "🗑️  Removendo recursos persistentes..."
	-aws --endpoint-url=$(ENDPOINT) s3 rb s3://$(BUCKET_NAME) --force

# ==========================================
# 3. TESTES E CARGA: Simulação de Tráfego
# ==========================================
test-confirm:
	@echo ""
	@echo "🧪 Infraestrutura ativa. Deseja iniciar a simulação de tráfego para monitoramento?"
	@read -p "🚀 Rodar Stress Test? [y/N]: " ans; \
	if [ "$$ans" = "y" ] || [ "$$ans" = "Y" ]; then \
		$(MAKE) stress-test; \
	else \
		echo "⏩ Simulação pulada. Execute 'make stress-test' quando desejar."; \
	fi

stress-test:
	@echo "🚀 Iniciando simulação de tráfego sustentado (3 ondas)..."
	@for wave in 1 2 3; do \
		echo "🌊 Onda $$wave: Enviando rajada de logs..."; \
		for i in 1 2 3 4 5; do \
			echo "EVENT_W$$wave_$$i: Log entry generated at $$(date)" > event_w$$wave_$$i.log; \
			curl -s -X PUT -T event_w$$wave_$$i.log $(ENDPOINT)/$(BUCKET_NAME)/event_w$$wave_$$i.log; \
		done; \
		echo "⏳ Aguardando consolidação de métricas (65s)..."; \
		sleep 65; \
	done
	@echo "✅ Simulação concluída! Verifique as séries temporais no Dashboard."

# ==========================================
# 4. UTILITÁRIOS: Inspeção e Limpeza
# ==========================================
list-db:
	@echo "📊 Estado atual da tabela DynamoDB:"
	aws --endpoint-url=$(ENDPOINT) dynamodb scan --table-name Tb_Logs_DevOps --query 'Items[*].{Arquivo:LockID.S, Status:Status.S}' --output table

clean-s3-logs:
	@echo "🧹 Limpando arquivos temporários do S3..."
	aws --endpoint-url=$(ENDPOINT) s3 ls s3://$(BUCKET_NAME) --recursive | grep ".log" | awk '{print $$4}' | xargs -I {} aws --endpoint-url=$(ENDPOINT) s3 rm s3://$(BUCKET_NAME)/{}