# Telegram Notification Role

An Ansible role that sends notifications to a Telegram chat.

## Requirements

- Ansible 2.10 or higher
- A Telegram bot token (create one with @BotFather)
- A Telegram chat ID

## Role Variables

Available variables are listed below:

```yaml
# Required variables
telegram_bot_token: ""      # Telegram Bot API token
telegram_chat_id: ""        # Telegram chat ID to send messages to
notification_subject: ""    # Subject line for the notification
notification_body: ""       # Body text for the notification
```

All of these variables are required for the role to function properly. The role will validate that these variables are set before attempting to send a notification.

## Example Playbook

```yaml
- hosts: all
  roles:
    - role: telegram_notification
      vars:
        telegram_bot_token: "YOUR_BOT_TOKEN"
        telegram_chat_id: "YOUR_CHAT_ID"
        notification_subject: "Ansible Notification"
        notification_body: "Task completed successfully"
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
        telegram_bot_token: "{{ telegram_bot_key }}"
        telegram_chat_id: "{{ telegram_chat_id }}"
        notification_subject: "System Update"
        notification_body: "Ubuntu updates completed on {{ inventory_hostname }}"
```

## Integration Example

Here's how to integrate the role with your existing playbooks:

```yaml
---
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
        telegram_bot_token: "{{ telegram_bot_token }}"
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
        telegram_bot_token: "{{ telegram_bot_token }}"
        telegram_chat_id: "{{ telegram_chat_id }}"
```

## Security Considerations

- It's recommended to store your Telegram bot token and chat ID in an encrypted file using Ansible Vault
- The role uses `no_log: true` to prevent sensitive data from appearing in logs

## Tags

The role includes the following tags:

- `telegram`: All Telegram-related tasks
- `notification`: All notification tasks

You can use these tags to selectively run or skip the notification tasks:

```bash
# Only run notification tasks
ansible-playbook playbook.yml --tags "notification"

# Skip notification tasks
ansible-playbook playbook.yml --skip-tags "notification"
```

## License

MIT