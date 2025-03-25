# Docker Compose Deploy Role

This Ansible role deploys Docker Compose applications and performs cleanup operations.

## Requirements

- Docker installed on the target host
- Docker Compose installed on the target host
- Ansible 2.10 or higher
- community.docker collection installed (`ansible-galaxy collection install community.docker`)

## Role Variables

- `docker_compose_project_dir`: Directory containing docker-compose.yml (default: ".")
- `docker_compose_file`: Docker compose file name (default: docker-compose.yml)

## Example Playbook

```yaml
---
- hosts: docker_servers
  roles:
    - role: docker_compose_deploy
      docker_compose_project_dir: /opt/myapp
```

## Usage with Tags

You can run specific parts of the role using tags:

```bash
# Pull images only
ansible-playbook playbook.yml --tags "pull"

# Deploy only
ansible-playbook playbook.yml --tags "deploy"

# Cleanup only
ansible-playbook playbook.yml --tags "cleanup"
```

## License

MIT