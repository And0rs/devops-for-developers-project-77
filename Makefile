TERRAFORM_DIR = ./terraform

tf-init:
	cd $(TERRAFORM_DIR) && terraform init

tf-validate:
	cd $(TERRAFORM_DIR) && terraform validate

tf-plan:
	cd $(TERRAFORM_DIR) && terraform plan

tf-apply:
	cd $(TERRAFORM_DIR) && terraform apply

tf-destroy:
	cd $(TERRAFORM_DIR) && terraform destroy

tf-output:
	cd $(TERRAFORM_DIR) && terraform output

decrypt-token:
	ansible-vault decrypt ./terraform/token.auto.tfvars

encrypt-token:
	ansible-vault encrypt ./terraform/token.auto.tfvars
