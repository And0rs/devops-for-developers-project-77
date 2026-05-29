TERRAFORM_DIR = ./terraform

TF = . ./.env && cd $(TERRAFORM_DIR) && terraform

tf-init:
	$(TF) init

tf-validate:
	$(TF) validate

tf-plan:
	$(TF) plan

tf-apply:
	$(TF) apply

tf-destroy:
	$(TF) destroy

tf-output:
	$(TF) output

# Ansible

ANSIBLE_DIR = ./ansible

ansible-install:
	cd $(ANSIBLE_DIR) && ansible-galaxy collection install -r requirements.yml

ansible-ping:
	ansible -i $(ANSIBLE_DIR)/inventory.ini -m ping all

ansible-playbook:
	ANSIBLE_CONFIG=$(ANSIBLE_DIR)/ansible.cfg ansible-playbook -i $(ANSIBLE_DIR)/inventory.ini $(ANSIBLE_DIR)/playbook.yml

ansible-check:
	ANSIBLE_CONFIG=$(ANSIBLE_DIR)/ansible.cfg ansible-playbook -i $(ANSIBLE_DIR)/inventory.ini $(ANSIBLE_DIR)/playbook.yml --check --diff

decrypt-token:
	ansible-vault decrypt ./terraform/token.auto.tfvars

encrypt-token:
	ansible-vault encrypt ./terraform/token.auto.tfvars
