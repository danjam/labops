# Ubuntu Update Role

An Ansible role that updates Ubuntu packages and manages system reboots when required.

## Overview

This role performs the following operations:
- Updates the apt package cache
- Upgrades packages based on configurable upgrade strategy
- Removes dependencies that are no longer required
- Checks if a reboot is required after updates
- Handles reboots automatically (optional)

## Requirements

- Ansible 2.10 or higher
- Ubuntu target system (specifically tested with 18.04, 20.04, 22.04, and 24.04)
- Sudo privileges on the target system

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

| Variable | Description | Default |
|----------|-------------|---------|
| `apt_cache_valid_time` | How long (in seconds) the apt cache should be considered valid | `3600` |
| `upgrade_type` | Type of upgrade to perform. Options: <br>- `safe`: upgrade only packages that won't remove others (apt-get upgrade)<br>- `full`: upgrade all packages, removing others if needed (apt-get dist-upgrade)<br>- `dist`: full upgrade, potentially adding new packages (apt full-upgrade) | `"safe"` |
| `auto_reboot` | Whether to automatically reboot if required after updates | `false` |
| `reboot_timeout` | How long (in seconds) to wait for the reboot to complete | `600` |
| `reboot_delay` | How long (in seconds) to wait before initiating the reboot | `5` |

## Tags

The role uses the following tags:

- `update`: Used for updating the apt cache and packages
- `packages`: General tag for package management tasks
- `cleanup`: For removing unused dependencies

## Example Playbook

Basic usage:

```yaml
- hosts: ubuntu
  roles:
    - role: ubuntu_update
```

With customized settings:

```yaml
- hosts: ubuntu
  roles:
    - role: ubuntu_update
      vars:
        upgrade_type: full
        auto_reboot: true
        reboot_timeout: 300
```

Run with specific tags:

```bash
# Only update packages without cleanup
ansible-playbook playbook.yml --tags "update"

# Only run cleanup tasks
ansible-playbook playbook.yml --tags "cleanup"
```

## Integration with Telegram Notifications

The ubuntu_update role can be integrated with the telegram_notification role for status alerts:

```yaml
- hosts: ubuntu
  vars_files:
    - vars/secrets.yml
  roles:
    - role: ubuntu_update
      vars:
        upgrade_type: full
        auto_reboot: true
  post_tasks:
    - name: Send notification about update completion
      include_role:
        name: telegram_notification
      vars:
        notification_subject: "System Update"
        notification_body: "✅ Ubuntu updates completed on {{ inventory_hostname }}"
        telegram_bot_token: "{{ telegram_bot_token }}"
        telegram_chat_id: "{{ telegram_chat_id }}"
```

## Handlers

The role includes the following handlers:

- `Check if reboot required`: Checks if a system reboot is required after package updates
- `Reboot if required`: Executes the reboot when necessary (only runs if `auto_reboot` is enabled)

## License

MIT