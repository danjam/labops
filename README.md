# LabOps: Homelab Infrastructure Management

![Ansible](https://img.shields.io/badge/Ansible-2.10+-black.svg?style=flat-square&logo=ansible)
![Ubuntu](https://img.shields.io/badge/Ubuntu-Support-orange.svg?style=flat-square&logo=ubuntu)
![Docker](https://img.shields.io/badge/Docker-Compose-blue.svg?style=flat-square&logo=docker)

A comprehensive Ansible infrastructure management system for your homelab environment, supporting multiple platforms including Ubuntu servers, Synology NAS, Windows and macOS workstations.

## 📋 Overview

LabOps automates three primary management tasks:

1. **System Updates** - Keep Ubuntu servers up-to-date with configurable upgrade types and automatic reboot handling
2. **Docker Deployments** - Deploy and maintain Docker Compose applications with proper resource cleanup
3. **Notifications** - Send status updates and alerts via Telegram

## 🗂️ Project Structure

```
.
├── ansible.cfg                  # Ansible configuration file
├── inventory/
│   └── inventory.yml            # Host inventory with platform and functional grouping
├── playbooks/
│   ├── docker_compose_deploy.yml # Docker deployment playbook
│   └── ubuntu_update.yml        # Ubuntu update playbook
├── roles/
│   ├── docker_compose_deploy/   # Role for Docker Compose deployments
│   ├── telegram_notification/   # Role for sending Telegram notifications
│   └── ubuntu_update/           # Role for Ubuntu system updates
├── run.sh                       # Wrapper script for running playbooks
├── requirements.yml             # Ansible Galaxy requirements
└── vars/
    └── secrets.yml.template     # Template for secrets configuration
```

## 🔧 Setup & Installation

### Prerequisites

- Ansible 2.10 or higher installed on your control node
- SSH access to target Linux/Unix hosts
- WinRM access to Windows hosts
- Sudo/Administrator privileges on managed systems

### Initial Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/labops.git
   cd labops
   ```

2. **Install required Ansible collections**

   ```bash
   ansible-galaxy collection install -r requirements.yml
   ```

3. **Configure your inventory**

   Copy the example inventory and modify it for your environment:

   ```bash
   cp inventory/inventory.yml inventory/my-inventory.yml
   # Edit inventory/my-inventory.yml with your hosts
   ```

4. **Set up Telegram notifications (optional)**

   Create your secrets file from the template:

   ```bash
   cp vars/secrets.yml.template vars/secrets.yml
   # Edit vars/secrets.yml with your Telegram bot token and chat ID
   ```

   Secure your secrets file:

   ```bash
   ansible-vault encrypt vars/secrets.yml
   ```

5. **Make the run script executable**

   ```bash
   chmod +x run.sh
   ```

## 🚀 Usage

### Running All Playbooks

Use the provided shell script to run all playbooks with password prompts:

```bash
./run.sh
```

### Running Individual Playbooks

```bash
# Update Ubuntu systems only
ansible-playbook playbooks/ubuntu_update.yml -kK

# Deploy Docker Compose applications only
ansible-playbook playbooks/docker_compose_deploy.yml -kK

# Using a custom inventory file
ansible-playbook -i inventory/my-inventory.yml playbooks/ubuntu_update.yml -kK
```

### Using with Vault-encrypted Secrets

If you've encrypted your secrets file:

```bash
ansible-playbook playbooks/your-playbook.yml -kK --ask-vault-pass
# Or using a vault password file
ansible-playbook playbooks/your-playbook.yml -kK --vault-password-file .vault_pass
```

## 🏷️ Using Tags

All roles support tags for granular execution:

### Ubuntu Update Tags

```bash
# Update package cache only
ansible-playbook playbooks/ubuntu_update.yml --tags "update"

# Update packages and perform cleanup
ansible-playbook playbooks/ubuntu_update.yml --tags "update,cleanup"
```

### Docker Compose Tags

```bash
# Deploy containers only
ansible-playbook playbooks/docker_compose_deploy.yml --tags "deploy"

# Clean up Docker resources only
ansible-playbook playbooks/docker_compose_deploy.yml --tags "cleanup"
```

## 🔍 Inventory Structure

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

## 📚 Role Documentation

### ubuntu_update

Updates Ubuntu systems with configurable options:

| Variable | Description | Default |
|----------|-------------|---------|
| `upgrade_type` | Type of upgrade: safe, full, or dist | `safe` |
| `auto_reboot` | Whether to reboot automatically if required | `false` |
| `reboot_timeout` | Maximum time (seconds) for reboot completion | `600` |
| `reboot_delay` | Delay (seconds) before initiating reboot | `5` |
| `apt_cache_valid_time` | How long (seconds) apt cache is valid | `3600` |

**Example:**

```yaml
- hosts: ubuntu
  roles:
    - role: ubuntu_update
      vars:
        upgrade_type: full
        auto_reboot: true
```

[Detailed ubuntu_update documentation](./roles/ubuntu_update/README.md)

### docker_compose_deploy

Manages Docker Compose applications:

| Variable | Description | Default |
|----------|-------------|---------|
| `docker_compose_project_dir` | Directory containing docker-compose.yml | `.` |
| `docker_compose_file` | Docker compose file name | `docker-compose.yml` |

**Example:**

```yaml
- hosts: docker_hosts
  roles:
    - role: docker_compose_deploy
      docker_compose_project_dir: /opt/homelab
```

[Detailed docker_compose_deploy documentation](./roles/docker_compose_deploy/README.md)

### telegram_notification

Sends notifications via Telegram:

| Variable | Description | Required |
|----------|-------------|----------|
| `telegram_bot_token` | Telegram Bot API token | Yes |
| `telegram_chat_id` | Telegram chat ID | Yes |
| `notification_subject` | Subject line for notification | Yes |
| `notification_body` | Body text for notification | Yes |

**Example:**

```yaml
- hosts: ubuntu
  roles:
    - role: ubuntu_update
  post_tasks:
    - name: Send notification
      include_role:
        name: telegram_notification
      vars:
        notification_subject: "System Update"
        notification_body: "Ubuntu updates completed on {{ inventory_hostname }}"
        telegram_bot_token: "{{ telegram_bot_key }}"
        telegram_chat_id: "{{ telegram_chat_id }}"
```

[Detailed telegram_notification documentation](./roles/telegram_notification/README.md)

## 🔄 Workflow Examples

### Complete System Management

Here's an example of a complete management workflow:

```yaml
---
# file: playbooks/complete_management.yml
- hosts: ubuntu
  vars_files:
    - vars/secrets.yml
  roles:
    - role: ubuntu_update
      vars:
        upgrade_type: full
        auto_reboot: true
  post_tasks:
    - name: Notify about update completion
      include_role:
        name: telegram_notification
      vars:
        notification_subject: "System Update"
        notification_body: "✅ Ubuntu update completed on {{ inventory_hostname }}"
        telegram_bot_token: "{{ telegram_bot_key }}"
        telegram_chat_id: "{{ telegram_chat_id }}"

- hosts: docker_hosts
  vars_files:
    - vars/secrets.yml
  roles:
    - role: docker_compose_deploy
      docker_compose_project_dir: /opt/homelab
  post_tasks:
    - name: Notify about Docker deployment
      include_role:
        name: telegram_notification
      vars:
        notification_subject: "Docker Deployment"
        notification_body: "🐳 Docker applications deployed on {{ inventory_hostname }}"
        telegram_bot_token: "{{ telegram_bot_key }}"
        telegram_chat_id: "{{ telegram_chat_id }}"
```

## ⚙️ Customization

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

## 🔒 Security Best Practices

- Replace the `-kK` flags (password prompts) with SSH key authentication
- Use Ansible Vault for storing sensitive information:
  ```bash
  ansible-vault create vars/secrets.yml
  ansible-vault edit vars/secrets.yml
  ```
- Consider using `ansible-vault encrypt_string` for encrypting individual variables
- Store vault passwords in a secure location or use a password manager integration

## ❓ Troubleshooting

### Connection Issues

- **SSH Connection Problems**:
  ```bash
  # Test SSH connection
  ansible all -m ping -u youruser -k
  ```

- **WinRM Connection Problems**:
  ```bash
  # Test WinRM connection
  ansible windows -m win_ping -u administrator -k
  ```

### Playbook Execution Issues

- **Verbose Output**: Add `-v`, `-vv`, or `-vvv` for increasing levels of verbosity
  ```bash
  ansible-playbook playbooks/ubuntu_update.yml -vvv
  ```

- **Check Mode**: Run in check mode to see what would change without making changes
  ```bash
  ansible-playbook playbooks/ubuntu_update.yml --check
  ```

### Docker Issues

- **Docker Compose File Not Found**:
  - Verify the path in `docker_compose_project_dir`
  - Confirm file permissions allow reading the compose file

- **Docker API Connection Errors**:
  - Ensure the Docker service is running: `systemctl status docker`
  - Check the user has permissions to access the Docker socket

## 📊 Maintenance

- Fact caching is enabled with a 24-hour timeout in the `.ansible_cache` directory
- The `.gitignore` file prevents sensitive information from being committed
- Consider adding scheduled execution via cron or systemd timers for automated maintenance

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

- danjam
