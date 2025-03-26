#!/bin/bash
set -e

export ANSIBLE_CONFIG="./ansible.cfg"

VAULT_FILE="./.vault_password"
VAULT_OPTION="--ask-vault-pass"

if [ -f "$VAULT_FILE" ] && [ -r "$VAULT_FILE" ]; then
    VAULT_OPTION="--vault-password-file $VAULT_FILE"
fi

# Run the main playbook that includes all roles
ansible-playbook $VAULT_OPTION -kK playbooks/labops.yml

# Uncomment below to run individual playbooks instead
# ansible-playbook $VAULT_OPTION -kK playbooks/ubuntu_update.yml
# ansible-playbook $VAULT_OPTION -kK playbooks/docker_compose_deploy.yml
