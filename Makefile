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

tf-to-ansible:
	. ./.env && cd $(TERRAFORM_DIR) && \
	echo "---" > ../$(ANSIBLE_DIR)/group_vars/tf_vars.yml && \
	echo "# Auto-generated from Terraform outputs. Do not edit manually." >> ../$(ANSIBLE_DIR)/group_vars/tf_vars.yml && \
	echo "tf_vm_1_ip: \"$$(terraform output -raw vm-1-public-ip)\"" >> ../$(ANSIBLE_DIR)/group_vars/tf_vars.yml && \
	echo "tf_vm_2_ip: \"$$(terraform output -raw vm-2-public-ip)\"" >> ../$(ANSIBLE_DIR)/group_vars/tf_vars.yml && \
	echo "tf_alb_ip: \"$$(terraform output -raw alb-public-ip)\"" >> ../$(ANSIBLE_DIR)/group_vars/tf_vars.yml && \
	echo "tf_domain: \"percacaosu.online\"" >> ../$(ANSIBLE_DIR)/group_vars/tf_vars.yml

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

ansible-vault-edit:
	ansible-vault edit $(ANSIBLE_DIR)/vars/vault.yml

ansible-vault-view:
	ansible-vault view $(ANSIBLE_DIR)/vars/vault.yml
