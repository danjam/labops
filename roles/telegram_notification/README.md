# Telegram Notification Role

An Ansible role that sends notifications to a Telegram chat.

## Requirements

- Ansible 2.10 or higher
- A Telegram bot token (create one with @BotFather)
- A Telegram chat ID

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
# Telegram Bot API token
telegram_bot_token: ""

# Telegram chat ID
telegram_chat_id: ""

# Message format
telegram_message_format: "🤖 *Ansible Notification*\n\n{% if task is defined %}Task: {{ task }}\n{% endif %}{% if host is defined %}Host: {{ inventory_hostname }}\n{% endif %}{% if message is defined %}{{ message }}{% endif %}"

# Whether notifications are enabled
telegram_notifications_enabled: true

# Notification level (all, success, failure)
telegram_notification_level: "all"
```

## Example Playbook

```yaml
- hosts: all
  roles:
    - role: telegram_notification
      vars:
        telegram_bot_token: "YOUR_BOT_TOKEN"
        telegram_chat_id: "YOUR_CHAT_ID"
        message: "Ansible task completed successfully"
```

## Using With Other Roles

You can use this role as a post-task notification:

```yaml
- hosts: ubuntu
  roles:
    - role: ubuntu_update
      vars:
        upgrade_type: full
        auto_reboot: true
  post_tasks:
    - name: Send notification
      include_role:
        name: telegram_notification
      vars:
        message: "Ubuntu updates completed on {{ inventory_hostname }}"
```

## Integration Example

Here's how to integrate the role with your existing playbooks:

```yaml
---
- hosts: ubuntu
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
        message: "✅ Ubuntu update completed on {{ inventory_hostname }}"

- hosts: docker_hosts
  roles:
    - role: docker_compose_deploy
      docker_compose_project_dir: /opt/homelab
  post_tasks:
    - name: Notify about Docker deployment
      include_role:
        name: telegram_notification
      vars:
        message: "🐳 Docker applications deployed on {{ inventory_hostname }}"
```

## License

MIT