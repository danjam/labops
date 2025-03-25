# Ubuntu Update Role

An Ansible role that updates Ubuntu packages and handles potential reboots.

## Requirements

This role requires Ansible 2.9 or higher.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
apt_cache_valid_time: 3600
upgrade_type: "safe"
auto_reboot: false
reboot_timeout: 600
reboot_delay: 5
```

- `apt_cache_valid_time`: How long (in seconds) the apt cache should be considered valid
- `upgrade_type`: Type of upgrade to perform (safe, full, dist)
- `auto_reboot`: Whether to automatically reboot if required after updates
- `reboot_timeout`: How long (in seconds) to wait for the reboot to complete
- `reboot_delay`: How long (in seconds) to wait before initiating the reboot

## Example Playbook

```yaml
- hosts: servers
  roles:
    - role: ubuntu_update
      vars:
        upgrade_type: full
        auto_reboot: true
```

## License

MIT
