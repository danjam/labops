# LabOps Notification Guide

LabOps supports multiple notification methods to keep you informed about maintenance operations, updates, and system alerts.

## Available Notification Methods

### Email Notifications

Email notifications send detailed information about operations to your specified email address.

**Configuration:**
```bash
# In labops.conf
SMTP_SERVER="smtp.gmail.com"
SMTP_PORT="587"
SMTP_USER="your-email@gmail.com"
SMTP_PASSWORD="your-app-password"
NOTIFICATION_EMAIL="admin@example.com"
```

**Note:** If using Gmail, you'll need to create an App Password:
1. Go to your Google Account > Security
2. Under "Signing in to Google," select App passwords
3. Generate a new app password for "Mail" and "Other (Custom name)"
4. Use this generated password in your configuration

### Webhook Notifications

Webhook notifications can integrate with various services like Slack, Discord, or custom systems.

**Configuration:**
```bash
# In labops.conf
NOTIFICATION_WEBHOOK_URL="https://hooks.example.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
NOTIFICATION_WEBHOOK_AUTH="Bearer your-token" # Optional
```

#### Slack Integration Example

For Slack, create an incoming webhook and use that URL:

1. Go to your Slack workspace > Administration > Manage Apps
2. Search for "Incoming WebHooks" and add to your workspace
3. Click "Add New Webhook to Workspace"
4. Choose the channel where notifications should appear
5. Copy the webhook URL and add it to your `labops.conf`

### Telegram Notifications

Telegram notifications send messages to a user or group chat via a Telegram bot.

**Configuration:**
```bash
# In labops.conf
TELEGRAM_BOT_TOKEN="your-bot-token"  # From @BotFather
TELEGRAM_CHAT_ID="your-chat-id"      # User or group chat ID
TELEGRAM_SILENT_NOTIFICATION="false" # Set to true for silent notifications
```

## Setting Up Telegram Notifications

1. **Create a Telegram Bot:**
   - Open Telegram and search for `@BotFather`
   - Send the command `/newbot`
   - Follow the instructions to create your bot
   - Save the token provided (e.g., `123456789:ABCdefGhIJKlmNoPQRsTUVwxyZ`)

2. **Get your Chat ID:**
   - For personal notifications:
     - Search for `@userinfobot` on Telegram
     - Start a chat and it will display your ID (e.g., `123456789`)
   - For group notifications:
     - Add your bot to the group
     - Send a message in the group mentioning the bot
     - Access https://api.telegram.org/bot{YOUR_BOT_TOKEN}/getUpdates
     - Find the "chat" object and copy the "id" value (usually negative for groups)

3. **Configure LabOps:**
   - Edit your `labops.conf` file
   - Add the following lines:
     ```
     TELEGRAM_BOT_TOKEN="your-bot-token"
     TELEGRAM_CHAT_ID="your-chat-id"
     ```

4. **Test the Notification:**
   - Run a test operation like:
     ```bash
     ./labops.sh --tags healthcheck
     ```
   - You should receive a notification in Telegram

## Notification Events

By default, LabOps sends notifications for the following events:

1. **Maintenance Start**: When a maintenance operation begins
2. **Maintenance Completion**: When a maintenance operation completes successfully
3. **System Health Alerts**: When health checks detect critical issues
4. **Update Failures**: When system updates fail
5. **Verification Failures**: When post-update verification fails

## Notification Format

All notification methods receive similar content:

- **Subject:** Operation type and host name
- **Time:** Timestamp of the operation
- **Host:** The server name and IP address
- **Message:** Details about the operation
- **Status:** Success or failure information

### Sample Email Notification

```
Subject: [Ansible] ✅ Maintenance completed on seraph

Host: seraph (100.76.155.100)
Time: 2025-03-21T14:30:45Z

System maintenance completed at 2025-03-21T14:30:45Z. Duration: 5.2 minutes

--
This is an automated message from Ansible
```

### Sample Telegram Notification

```
✅ Maintenance completed on seraph

Host: seraph (100.76.155.100)
Time: 2025-03-21T14:30:45Z

System maintenance completed at 2025-03-21T14:30:45Z. Duration: 5.2 minutes
```

## Enabling Notifications

To enable notifications for all hosts, set the following variable in your inventory file:

```yml
# In inventory/inventory.yml under vars section
enable_monitoring: yes
```

To enable notifications for specific host groups, add the variable to the group's vars section:

```yml
ubuntu:
  vars:
    notification_enabled: yes
```

## Multiple Notification Methods

You can configure multiple notification methods simultaneously. LabOps will send notifications to all configured channels.

## Customizing Notifications

The notification system uses the `send_notification.yml` task file. This file handles:

- Checking required variables
- Determining which notification methods to use
- Sending notifications via each configured method
- Logging notification status

If you want to customize notification content or add additional notification methods, you can modify this file.

## Troubleshooting Notifications

If notifications aren't working:

1. **Check Configuration**:
   - Verify credentials in `labops.conf`
   - Ensure the notification_enabled variable is set

2. **Test Email Settings**:
   ```bash
   # Test SMTP connection
   telnet smtp.gmail.com 587
   ```

3. **Test Telegram Bot**:
   ```bash
   # Test Telegram API
   curl -X POST https://api.telegram.org/bot{YOUR_BOT_TOKEN}/getMe
   ```

4. **Check Logs**:
   - Look for notification-related entries in your logs
   - Run with increased verbosity: `./labops.sh -vvv`

5. **Firewall Issues**:
   - Ensure your control node can reach the notification services
   - Check if corporate firewalls might be blocking outbound connections