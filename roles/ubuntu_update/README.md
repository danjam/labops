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

## Tags

The role uses the following tags:

- `update`: Used for updating the apt cache and packages
- `packages`: General tag for package management tasks
- `cleanup`: For removing unused dependencies

Run with specific tags:

```bash
# Only update packages without cleanup
ansible-playbook playbook.yml --tags "update"

# Only run cleanup tasks
ansible-playbook playbook.yml --tags "cleanup"
```

## Integration with Other Roles

### Telegram Notifications

This role can be integrated with the telegram_notification role for status alerts:

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

## Advanced Usage

### Limiting Update Scope

To focus updates on specific packages or exclude certain packages, you can add pre-tasks to your playbook:

```yaml
- hosts: ubuntu
  pre_tasks:
    - name: Hold specific packages
      ansible.builtin.dpkg_selections:
        name: postgresql-12
        selection: hold
  roles:
    - role: ubuntu_update
```

### Handling Large Systems

For systems with many packages or limited resources, you can adjust the approach:

```yaml
- hosts: ubuntu
  roles:
    - role: ubuntu_update
      vars:
        upgrade_type: safe  # More conservative upgrade strategy
        apt_cache_valid_time: 86400  # Longer cache validity (24 hours)
```

## Compatibility

This role is compatible with the following Ubuntu versions:
- Ubuntu 18.04 Bionic Beaver
- Ubuntu 20.04 Focal Fossa
- Ubuntu 22.04 Jammy Jellyfish
- Ubuntu 24.04 Noble Numbat

## License

MIT