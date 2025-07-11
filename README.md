# labops

A simple Ansible automation tool for managing Ubuntu homelab servers with Docker.

## What it does

This playbook automates common homelab maintenance tasks:

- ✅ Updates Ubuntu packages and handles reboots
- 🐳 Installs/manages Docker and Docker Compose
- 📦 Updates Docker Compose stacks with latest images
- 🧹 Cleans up unused Docker resources
- 📊 Provides detailed status reporting

## Prerequisites

- Ansible installed on your control machine
- Ubuntu servers with SSH access
- Sudo privileges on target servers
- Docker Compose files located in `/opt/homelab/` on target servers

## Setup

1. Create an inventory file `hosts.ini`:
```ini
[ubuntu_servers]
server1.local ansible_user=your_username
server2.local ansible_user=your_username
```

2. Make the run script executable:
```bash
chmod +x run.sh
```

## Usage

Run the automation:
```bash
./run.sh
```

You'll be prompted for:
- SSH password (or use SSH keys)
- Sudo password

## Configuration

The playbook expects Docker Compose files in `/opt/homelab/` by default. To change this, edit the `docker_compose_path` variable in the playbook.

## Tags

Run specific parts of the playbook:
```bash
# Only system updates
ansible-playbook -i hosts.ini playbook.ubuntu-docker-update.yml --tags update

# Only Docker operations
ansible-playbook -i hosts.ini playbook.ubuntu-docker-update.yml --tags docker
```

## License

MIT License - see LICENSE file for details.
