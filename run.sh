export ANSIBLE_CONFIG=./ansible.cfg
ansible-playbook playbooks/ubuntu_update.yml playbooks/docker_compose_deploy.yml -kK