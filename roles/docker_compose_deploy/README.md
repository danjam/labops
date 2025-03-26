# Docker Compose Deploy Role

This Ansible role manages Docker Compose applications by handling deployment, updates, and resource cleanup operations.

## Overview

The docker_compose_deploy role provides the following functionality:
- Starts or updates Docker Compose services
- Automatically pulls the latest Docker images
- Removes orphaned containers
- Cleans up unused Docker resources (containers, images, networks, volumes)

## Requirements

This role has the following dependencies:
- Docker Engine must be installed on the target host
- Docker Compose V2 must be installed on the target host (using the `docker compose` plugin format)
- Ansible 2.10 or higher
- community.docker collection installed

> **Note:** This role will check if Docker and Docker Compose are properly installed and available on the target host. If either dependency is missing, the role will fail with an appropriate error message. **The role does not install Docker or Docker Compose for you** - you should ensure these are installed beforehand or use a dedicated role for installing Docker before including this role.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

| Variable | Description | Default |
|----------|-------------|---------|
| `docker_compose_project_dir` | Directory containing docker-compose.yml | `"."` |
| `docker_compose_file` | Docker compose file name | `docker-compose.yml` |

## Example Playbook

Basic usage with defaults:

```yaml
---
- hosts: docker_servers
  roles:
    - role: docker_compose_deploy
```

Setting custom Docker Compose directory:

```yaml
---
- hosts: docker_servers
  roles:
    - role: docker_compose_deploy
      vars:
        docker_compose_project_dir: /opt/myapp
        docker_compose_file: docker-compose.prod.yml
```

## Tags

This role supports the following tags for granular execution:

| Tag | Description |
|-----|-------------|
| `deploy` | Pull images and deploy/update containers |
| `cleanup` | Remove unused Docker resources |

Usage examples:

```bash
# Pull images and deploy only
ansible-playbook playbook.yml --tags "deploy"

# Cleanup only
ansible-playbook playbook.yml --tags "cleanup"
```

## Integration with Other Roles

### Telegram Notifications

This role can be integrated with the telegram_notification role for status alerts:

```yaml
---
- hosts: docker_hosts
  vars_files:
    - vars/secrets.yml
  roles:
    - role: docker_compose_deploy
      vars:
        docker_compose_project_dir: /opt/homelab
  post_tasks:
    - name: Notify about Docker deployment
      include_role:
        name: telegram_notification
      vars:
        notification_subject: "Docker Deployment"
        notification_body: "🐳 Docker applications deployed on {{ inventory_hostname }}"
        telegram_bot_token: "{{ telegram_bot_token }}"
        telegram_chat_id: "{{ telegram_chat_id }}"
```

## Advanced Usage

### Multiple Docker Compose Files

To deploy multiple Docker Compose applications:

```yaml
---
- hosts: docker_servers
  tasks:
    - name: Deploy app1
      include_role:
        name: docker_compose_deploy
      vars:
        docker_compose_project_dir: /opt/app1
        
    - name: Deploy app2
      include_role:
        name: docker_compose_deploy
      vars:
        docker_compose_project_dir: /opt/app2
```

### Dependency Installation

This role doesn't install Docker or Docker Compose for you. If you need to install these dependencies, consider using a dedicated role or tasks before including the docker_compose_deploy role:

```yaml
---
- hosts: docker_servers
  roles:
    # Install Docker first
    - role: some.docker_installation_role
    
    # Then deploy Docker Compose applications
    - role: docker_compose_deploy
```

### Resource Management

The role automatically performs cleanup operations to prevent resource accumulation. The cleanup process:

- Removes unused containers
- Prunes unused images (including non-dangling ones)
- Cleans up unused networks
- Removes unused volumes
- Purges the builder cache

This helps prevent disk space issues on long-running Docker hosts.

## Troubleshooting

Common issues and their solutions:

1. **Permission denied error**: Ensure the executing user has permissions to access the Docker socket
   ```bash
   # Add user to docker group
   sudo usermod -aG docker your_ansible_user
   ```

2. **Docker Compose file not found**: Verify the path in `docker_compose_project_dir` and ensure the file exists

3. **Networking issues when pulling images**: Check that the host has internet access and can reach Docker Hub or your private registry

4. **Resource cleanup fails**: The cleanup operations require additional permissions; ensure the user has full Docker admin rights

5. **Docker or Docker Compose not found**: The role will check for these dependencies and fail with a clear error message. Install Docker and Docker Compose on the target host before running this role.

## Compatibility

This role is compatible with:

- Docker Engine 20.10.x and newer
- Docker Compose V2 (using the `docker compose` plugin format)
- Ubuntu, Debian, and EL (RHEL/CentOS) operating systems

## License

MIT