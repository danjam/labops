# Telegram Notification Role

An Ansible role that sends notifications to a Telegram chat.

## Overview

This role provides a simple way to send notifications from your Ansible playbooks to a Telegram chat. Features include:
- Markdown formatted messages
- Subject/body structure for clear organization
- Validation of required parameters
- Easy integration with other roles

## Requirements

- Ansible 2.10 or higher
- A Telegram bot token (create one with [@BotFather](https://t.me/botfather))
- A Telegram chat ID

## Role Variables

Available variables are listed below:

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `telegram_bot_token` | Telegram Bot API token | Yes | None |
| `telegram_chat_id` | Telegram chat ID to send messages to | Yes | None |
| `notification_subject` | Subject line for the notification | Yes | None |
| `notification_body` | Body text for the notification | Yes | None |

All of these variables are required for the role to function properly. The role will validate that these variables are set before attempting to send a notification.

## Example Playbook

Basic usage:

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
        telegram_bot_token: "{{ telegram_bot_token }}"
        telegram_chat_id: "{{ telegram_chat_id }}"
        notification_subject: "System Update"
        notification_body: "Ubuntu updates completed on {{ inventory_hostname }}"
```

## Advanced Usage

### Adding Variables to Notification Messages

You can include Ansible variables in your notification messages:

```yaml
- name: Send detailed notification
  include_role:
    name: telegram_notification
  vars:
    notification_subject: "System Report: {{ inventory_hostname }}"
    notification_body: |
      📊 *System Status Report*
      
      🖥️ **Hostname**: {{ inventory_hostname }}
      💾 **Free Disk Space**: {{ ansible_facts.mounts[0].size_available | human_readable }}
      🔄 **Uptime**: {{ ansible_facts.uptime_seconds | human_time }}
      🌡️ **Load Average**: {{ ansible_facts.loadavg.1 }}
```

### Conditionally Sending Notifications

You can conditionally send notifications based on task results:

```yaml
- name: Check application status
  command: systemctl status myapp
  register: app_status
  failed_when: false
  changed_when: false

- name: Send alert if application is down
  include_role:
    name: telegram_notification
  vars:
    notification_subject: "❌ Application Alert"
    notification_body: "Application myapp is not running on {{ inventory_hostname }}"
  when: app_status.rc != 0
```

## Error Handling

The role provides robust error handling capabilities for Telegram notifications:

| Variable | Description | Default |
|----------|-------------|---------|
| `telegram_fail_silently` | Whether to continue playbook execution if notification fails | `false` |
| `telegram_retry_attempts` | Number of retry attempts for sending notifications | `3` |
| `telegram_retry_delay` | Delay between retry attempts (in seconds) | `5` |
| `telegram_timeout` | Timeout for the HTTP request (in seconds) | `30` |

### Available Status Variables

After a notification attempt, the role sets these variables that can be checked in subsequent tasks:

- `telegram_notification_sent`: Boolean indicating whether the notification was successfully sent
- `telegram_notification_failed`: Boolean set to true if the notification failed
- `telegram_error_message`: Contains the error message if the notification failed

### Error Handling Examples

**Silent error handling:**

```yaml
- name: Send notification with silent error handling
  include_role:
    name: telegram_notification
  vars:
    telegram_bot_token: "{{ telegram_bot_token }}"
    telegram_chat_id: "{{ telegram_chat_id }}"
    notification_subject: "System Update"
    notification_body: "Task completed on {{ inventory_hostname }}"
    telegram_fail_silently: true

- name: Check if notification was sent
  debug:
    msg: "Notification was not sent. Error: {{ telegram_error_message }}"
  when: telegram_notification_failed | default(false)
```

**With retries and extended timeout:**

```yaml
- name: Send critical notification with extended timeout and retries
  include_role:
    name: telegram_notification
  vars:
    telegram_bot_token: "{{ telegram_bot_token }}"
    telegram_chat_id: "{{ telegram_chat_id }}"
    notification_subject: "CRITICAL: System Alert"
    notification_body: "Critical issue detected on {{ inventory_hostname }}"
    telegram_retry_attempts: 5
    telegram_retry_delay: 10
    telegram_timeout: 60
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