# LabOps Installation Guide

This guide will walk you through the process of setting up LabOps for your home lab environment, from initial installation to advanced configuration.

## System Requirements

### Control Node Requirements

The control node is the system where you run LabOps from:

- **Operating System**: Any Linux distribution, macOS, or Windows with WSL
- **Software**:
  - Python 3.8 or newer
  - Ansible 2.12 or newer
  - Git
- **Network**: 
  - SSH access to managed hosts
  - Internet connectivity for updates and notifications
- **Permissions**:
  - Sudo/root access for running Ansible

### Managed Node Requirements

Requirements for systems managed by LabOps:

- **SSH access** or WinRM (for Windows hosts)
- **Python 3.6+** (automatically detected by Ansible)
- **Sudo/root privileges** for system operations
- **Docker** and **Docker Compose v2** (for container management features)

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/danjam/labops.git
cd labops
```

### 2. Install Required Ansible Collections

LabOps requires several Ansible collections to function properly:

```bash
# Option 1: Install all collections at once
ansible-galaxy collection install -r requirements.yml

# Option 2: Install collections individually
ansible-galaxy collection install community.general
ansible-galaxy collection install community.docker
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install ansible.windows
```

### 3. Make the Script Executable

```bash
chmod +x labops.sh
```

### 4. Configure Your Inventory

The inventory file defines the systems LabOps will manage. Edit `inventory/inventory.yml` to add your systems:

```bash
vi inventory/inventory.yml
```

#### Inventory Organization

The inventory is structured in several layers:

1. **OS-based groups**: Systems organized by operating system
   - `ubuntu`: Ubuntu Linux systems
   - `synology`: Synology NAS devices
   - `windows`: Windows systems
   - `apple`: macOS systems

2. **Functional groups**: Systems organized by purpose
   - `storage`: Storage servers and NAS devices
   - `workstations`: Desktop and laptop computers
   - `homelab`: Lab servers and infrastructure

3. **OS-family groups**: Higher-level grouping
   - `linux`: All Linux-based systems
   - `unix_like`: Linux, macOS, and Unix-like systems
   - `all_systems`: Every system in your inventory

#### Example Host Configuration

For each host, you'll need to specify connection details:

```yml
# Ubuntu server example
seraph:
  ansible_host: 192.168.1.100
  ansible_user: admin
  ansible_become: yes
  ansible_become_method: sudo

# Windows system example
nucleus:
  ansible_host: 192.168.1.150
  ansible_user: administrator
  ansible_connection: winrm
  ansible_winrm_server_cert_validation: ignore

# Synology NAS example
harlans_world:
  ansible_host: 192.168.1.200
  ansible_user: admin
  ansible_become: yes
```

#### Group Variables

You can set variables for entire groups of hosts:

```yml
ubuntu:
  vars:
    ansible_python_interpreter: auto_silent
    update_timeout: 600
    reboot_timeout: 300
    critical_services:
      - ssh
      - docker
```

#### Global Variables

Variables that apply to all hosts:

```yml
all:
  vars:
    ansible_connection: ssh
    ansible_ssh_timeout: 30
    default_docker_path: /opt/homelab
    notification_email: admin@example.com
    enable_monitoring: yes
```

### 5. Configure Global Settings

Edit the `labops.conf` file to customize default behavior:

```bash
vi labops.conf
```

Key settings include:

#### Default Paths and Authentication
```bash
# Default inventory and playbook
INVENTORY="inventory/inventory.yml"
PLAYBOOK="playbooks/homelab_maintenance.yml"

# Default to asking for passwords (set to empty string to disable)
ASK_PASS="-kK"

# Default verbosity (can be empty, -v, -vv, or -vvv)
VERBOSE=""
```

#### Notification Settings
```bash
# Email notification settings
SMTP_SERVER="smtp.gmail.com"
SMTP_PORT="587"
SMTP_USER="your-email@gmail.com"
SMTP_PASSWORD="your-app-password"
NOTIFICATION_EMAIL="admin@example.com"

# Telegram notification settings
TELEGRAM_BOT_TOKEN="your-bot-token"
TELEGRAM_CHAT_ID="your-chat-id"
TELEGRAM_SILENT_NOTIFICATION="false"
```

#### System and Docker Settings
```bash
# Docker settings
DOCKER_PATH="/opt/homelab"
DOCKER_PRUNE_VOLUMES="false"

# System update settings
REBOOT_ON_KERNEL_UPDATE="true"
UPDATE_TIMEOUT="600"
REBOOT_TIMEOUT="300"
POST_REBOOT_DELAY="30"

# Critical services to monitor
CRITICAL_SERVICES="ssh docker"
```

### 6. Setup SSH Keys (Optional but Recommended)

For passwordless automation, set up SSH keys:

```bash
# Generate an SSH key if you don't have one
ssh-keygen -t ed25519 -C "labops"

# Copy your key to each host (repeat for each host)
ssh-copy-id user@host
```

If you set up SSH keys, you can use the `--no-password` option:

```bash
./labops.sh --no-password
```

### 7. Verify Your Installation

Run a simple check to verify everything is set up correctly:

```bash
# List all hosts in your inventory
./labops.sh --list-hosts

# Run a health check to verify connectivity
./labops.sh --tags healthcheck
```

## Advanced Configuration

### Adding New Systems

To add a new system to LabOps:

1. Add the host to your inventory in `inventory/inventory.yml`
2. Ensure SSH access is configured
3. Run a health check to verify connectivity:
   ```bash
   ./labops.sh --tags healthcheck --limit new-host
   ```

### Customizing Task Behavior

Many tasks have configurable variables. Set these in your inventory:

```yml
# In inventory/inventory.yml
ubuntu:
  vars:
    # Hold specific packages during updates
    held_packages:
      - mysql-server
      - nginx
    
    # Customize reboot behavior
    reboot_on_kernel_update: true
    reboot_timeout: 300
```

### Configuring Notifications

See the [Notification Guide](notifications.md) for detailed setup instructions.

### Automating with Cron

Schedule regular maintenance with cron:

```bash
# Edit your crontab
crontab -e
```

Example cron entries:

```cron
# Weekly maintenance (Sunday at 2 AM)
0 2 * * 0 /path/to/labops/labops.sh --no-password > /path/to/labops/logs/cron.log 2>&1

# Daily health check (7 AM)
0 7 * * * /path/to/labops/labops.sh --no-password --tags healthcheck > /path/to/labops/logs/healthcheck.log 2>&1
```

## Troubleshooting

### Common Installation Issues

#### Ansible Not Found

```
-bash: ansible-playbook: command not found
```

**Solution**: Install Ansible:
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install ansible

# macOS
brew install ansible

# Pip (any platform)
pip install ansible
```

#### SSH Connection Issues

```
fatal: [host]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host...
```

**Solutions**:
- Verify SSH is running on the target: `ssh user@host`
- Check for firewalls blocking port 22
- Verify credentials in inventory file
- Try with verbose output: `./labops.sh -vvv`

#### Python Interpreter Issues

```
fatal: [host]: FAILED! => {"changed": false, "msg": "Failed to import the required Python library...
```

**Solution**: Set the Python interpreter in your inventory:
```yml
all:
  vars:
    ansible_python_interpreter: /usr/bin/python3
```

#### Permission Denied

```
fatal: [host]: FAILED! => {"changed": false, "msg": "Permission denied"...
```

**Solutions**:
- Verify sudo rights for the user
- Check if password is required (use `-kK` or configure SSH keys)
- Verify ansible_become settings in inventory

### Verifying Requirements

Check if systems meet requirements:

```bash
# Verify Ansible version
ansible --version

# Check connectivity to hosts
ansible all -i inventory/inventory.yml -m ping

# Check Python versions
ansible all -i inventory/inventory.yml -m raw -a "python3 --version || python --version"

# Check for Docker
ansible all -i inventory/inventory.yml -m shell -a "command -v docker || echo 'Docker not installed'"
```

### Getting Detailed Logs

For troubleshooting, increase verbosity:

```bash
# Maximum verbosity
./labops.sh -vvv

# Check logs for errors
grep -r "ERROR\|FAILED\|UNREACHABLE" logs/
```

## Next Steps

Now that you've completed installation:

1. See the [Usage Guide](usage.md) for day-to-day operations
2. Configure [Notifications](notifications.md) to stay informed
3. Run your first maintenance operation:
   ```bash
   ./labops.sh
   ```

For further questions or issues, please check the project documentation or open an issue on GitHub.