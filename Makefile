TERRAFORM_APPLY = terraform apply -auto-approve
TERRAFORM_KILL  = terraform destroy -auto-approve
TERRAFORM_PLAN  = terraform plan

# ---------------------------------------------------------------------------
# Build — neamsoft-sendmail
# ---------------------------------------------------------------------------
SENDMAIL_API = rm -Rf neamsoft-sendmail.zip ; \
	cd ../neamsoft-backend/sendmail ; \
	zip -r ../../neamsoft-IaaS/neamsoft-sendmail.zip * ; \

# ---------------------------------------------------------------------------
# Targets
# ---------------------------------------------------------------------------
build_sendmail:
	@$(SENDMAIL_API)
	@printf "| ✅ Build neamsoft-sendmail completado |\n"

# ---------------------------------------------------------------------------
# Deploy
# ---------------------------------------------------------------------------
plan:
	@export TF_CLI_ARGS='-var-file=envs.tfvars' && \
	$(TERRAFORM_PLAN)

deploy:
	@$(SENDMAIL_API)
	@printf "| ✅ Build completado, desplegando...\n"
	@export TF_CLI_ARGS='-var-file=envs.tfvars' && \
	$(TERRAFORM_APPLY)

destroy:
	@export TF_CLI_ARGS='-var-file=envs.tfvars' && \
	$(TERRAFORM_KILL)

# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------
default:
	@echo 'Usa: make help'

help:
	@printf "\nneamsoft IaaS — Comandos disponibles:\n"
	@printf "=====================================================\n"
	@printf "| make build_sendmail  : Empaqueta Lambda sendmail  |\n"
	@printf "| make plan            : Terraform plan             |\n"
	@printf "| make deploy          : Build + Deploy completo    |\n"
	@printf "| make destroy         : Destruir infraestructura   |\n"
	@printf "=====================================================\n"

.DEFAULT_GOAL := default
