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

# Ansible

ANSIBLE_DIR = ./ansible

ansible-install:
	cd $(ANSIBLE_DIR) && ansible-galaxy collection install -r requirements.yml

ansible-ping:
	ansible -i $(ANSIBLE_DIR)/inventory.ini -m ping all

ansible-playbook:
	ansible-playbook -i $(ANSIBLE_DIR)/inventory.ini $(ANSIBLE_DIR)/playbook.yml

ansible-check:
	ansible-playbook -i $(ANSIBLE_DIR)/inventory.ini $(ANSIBLE_DIR)/playbook.yml --check --diff

decrypt-token:
	ansible-vault decrypt ./terraform/token.auto.tfvars

encrypt-token:
	ansible-vault encrypt ./terraform/token.auto.tfvars
