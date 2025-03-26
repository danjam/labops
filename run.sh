#!/bin/bash
set -e

export ANSIBLE_CONFIG="./ansible.cfg"

VAULT_FILE="./.vault_password"
VAULT_OPTION="--ask-vault-pass"

if [ -f "$VAULT_FILE" ] && [ -r "$VAULT_FILE" ]; then
    VAULT_OPTION="--vault-password-file $VAULT_FILE"
fi

# ansible-playbook -kK playbooks/ubuntu_update.yml playbooks/docker_compose_deploy.yml

 ansible-playbook $VAULT_OPTION -kK playbooks/labops.yml -kK

