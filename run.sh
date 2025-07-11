#!/bin/sh

ansible-playbook -i hosts.ini playbook.ubuntu-docker-update.yml -K -k
