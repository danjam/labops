# LabOps

This project contains Ansible roles and playbooks for managing a homelab environment with multiple systems including Ubuntu servers, Synology NAS, Windows and macOS workstations.

## Overview

This Ansible project automates two primary tasks:
1. System updates for Ubuntu servers
2. Docker Compose application deployment and maintenance

## Project Structure

```
.
├── ansible.cfg                  # Ansible configuration file
├── inventory/
│   └── inventory.yml            # Host inventory with grouping structure
├── playbooks/
│   ├── docker_compose_deploy.yml # Docker deployment playbook
│   └── ubuntu_update.yml        # Ubuntu update playbook
├── roles/
│   ├── docker_compose_deploy/   # Role for Docker Compose deployments
│   └── ubuntu_update/           # Role for Ubuntu system updates
└── run.sh                       # Wrapper script for running playbooks
```

## Inventory Structure

The inventory is organized into several levels:

### OS-based Groups
- `ubuntu`: Ubuntu servers
- `synology`: Synology NAS devices
- `windows`: Windows workstations
- `apple`: macOS devices

### Functional Groups
- `storage`: Storage servers
- `workstations`: User workstations
- `homelab`: Lab environment servers
- `docker_hosts`: Servers running Docker

### Hierarchy Groups
- `linux`: All Linux-based systems
- `unix_like`: Linux and macOS systems
- `all_systems`: All managed systems

## Roles

### ubuntu_update

Updates Ubuntu systems with configurable options:

- `upgrade_type`: Type of upgrade (safe, full, dist)
- `auto_reboot`: Whether to reboot automatically if required
- `reboot_timeout`: Maximum time for reboot completion
- `reboot_delay`: Delay before initiating reboot

[Full ubuntu_update documentation](./roles/ubuntu_update/README.md)

### docker_compose_deploy

Manages Docker Compose applications:

- Pulls latest Docker images
- Deploys applications with Docker Compose
- Performs cleanup of unused Docker resources

[Full docker_compose_deploy documentation](./roles/docker_compose_deploy/README.md)

## Usage

### Requirements

- Ansible 2.10 or higher
- SSH access to target hosts
- Sudo privileges on managed systems
- community.docker collection (`ansible-galaxy collection install community.docker`)

### Running Playbooks

Use the provided shell script to run all playbooks:

```bash
./run.sh
```

Or run individual playbooks:

```bash
# Update Ubuntu systems only
ansible-playbook playbooks/ubuntu_update.yml -kK

# Deploy Docker Compose applications only
ansible-playbook playbooks/docker_compose_deploy.yml -kK
```

### Using Tags

Both roles support tags for granular execution:

```bash
# Update packages only
ansible-playbook playbooks/ubuntu_update.yml --tags "update"

# Pull Docker images only
ansible-playbook playbooks/docker_compose_deploy.yml --tags "pull"

# Clean up Docker resources only
ansible-playbook playbooks/docker_compose_deploy.yml --tags "cleanup"
```

## Configuration

### Changing Update Behavior

Edit `playbooks/ubuntu_update.yml` to modify the update behavior:

```yaml
- hosts: ubuntu
  roles:
    - role: ubuntu_update
      vars:
        upgrade_type: full    # Options: safe, full, dist
        auto_reboot: true     # Whether to reboot automatically
```

### Changing Docker Compose Directory

Edit `playbooks/docker_compose_deploy.yml` to modify the Docker Compose directory:

```yaml
- hosts: docker_hosts
  roles:
    - role: docker_compose_deploy
      docker_compose_project_dir: /path/to/docker/compose
```

## Security Notes

- The current setup uses `-kK` flags which prompt for passwords
- Consider implementing Ansible Vault for secure credential management
- SSH keys are recommended over password authentication

## Maintenance

- Fact caching is enabled with a 24-hour timeout in the `.ansible_cache` directory
- The `.gitignore` file prevents sensitive information from being committed

## Author

- danjam