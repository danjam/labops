# LabOps Usage Guide

This guide explains how to effectively use LabOps for maintaining your home lab environment, with practical examples and best practices.

## Core Concepts

LabOps organizes maintenance operations into distinct categories:

- **Health Checks**: System status monitoring
- **System Updates**: OS and package updates
- **Docker Management**: Container and image updates
- **Verification**: Post-update system validation
- **Notifications**: Alerts for maintenance events

These operations can be run individually or as part of a complete maintenance workflow.

## Command-Line Interface

The `labops.sh` script provides a convenient interface to Ansible:

```
Usage: ./labops.sh [options]

Options:
  -i, --inventory INVENTORY  Specify inventory file
  -p, --playbook PLAYBOOK    Specify playbook file
  -t, --tags TAGS            Specify tags (e.g., system,docker)
  -v, --verbose              Increase verbosity (-v, -vv, or -vvv)
  -S, --no-password          Don't ask for passwords (use SSH keys)
  -l, --limit HOSTS          Limit execution to specified hosts
  -c, --check                Run in check mode (dry run)
  --list-hosts               List all hosts in the inventory
  --version                  Show version information
  -h, --help                 Show this help message
```

## Basic Usage

### Running a Full Maintenance Operation

To perform a complete maintenance operation on all systems:

```bash
./labops.sh
```

This will execute the full maintenance workflow:

1. Initial health checks on all systems
2. System updates with controlled reboots if needed
3. Docker container updates and management
4. System verification to confirm successful updates
5. Notification of completion status

### Targeting Specific Hosts

You can limit operations to specific hosts or groups:

```bash
# Target a single host
./labops.sh --limit seraph

# Target a group of hosts
./labops.sh --limit ubuntu

# Target multiple specific hosts
./labops.sh --limit "seraph,jarvis"

# Target hosts by function
./labops.sh --limit workstations
```

### Running Specific Tasks

Use tags to run only specific types of tasks:

```bash
# Only run health checks
./labops.sh --tags healthcheck

# Only run system updates
./labops.sh --tags system

# Only run Docker tasks
./labops.sh --tags docker

# Run both system and Docker tasks
./labops.sh --tags "system,docker"
```

## Advanced Usage

### Dry Run Mode (Check Mode)

To preview changes without applying them:

```bash
./labops.sh --check
```

This shows what would change without making actual modifications - useful for validating updates before running them.

### Verbosity Levels

Control the amount of output with verbosity flags:

```bash
# Normal output
./labops.sh

# Increased detail
./labops.sh -v

# Debug-level detail
./labops.sh -vv

# Maximum detail
./labops.sh -vvv
```

Higher verbosity is useful for troubleshooting issues or understanding exactly what's happening.

### Authentication Options

Choose between password prompts or SSH keys:

```bash
# With password prompts
./labops.sh

# Without password prompts (requires SSH keys)
./labops.sh --no-password
```

Setting up SSH keys is recommended for automation.

## Task Workflows

### Health Check Workflow

The health check task (`--tags healthcheck`) performs:

1. **System Connectivity Test**: Verifies host is reachable
2. **System Information Collection**: Gathers hardware, virtual, and network info
3. **Disk Space Check**: Monitors all mounted filesystems
4. **Memory Usage Check**: Detects high memory usage
5. **System Load Check**: Monitors processor load
6. **Process Count Check**: Counts running processes
7. **Update Availability Check**: Counts available system updates
8. **Warning Generation**: Alerts on high disk usage, memory, or load
9. **Health Evaluation**: Determines overall system health

Health checks will fail if multiple critical issues are detected.

### System Update Workflow

The system update task (`--tags system`) performs:

1. **System Validation**: Verifies OS compatibility
2. **Package Hold Management**: Preserves specified packages
3. **Update Preparation**: Updates package cache
4. **System Upgrade**: Performs full system upgrade
5. **Cleanup**: Removes unused packages
6. **Update Summary**: Records what was changed
7. **Reboot Detection**: Identifies when reboot is needed
8. **Controlled Reboot**: Safely reboots if required
9. **Service Validation**: Verifies services after update

### Docker Management Workflow

The Docker management task (`--tags docker`) performs:

1. **Service Check**: Verifies Docker service is running
2. **Daemon Health Check**: Validates Docker daemon
3. **Compose File Discovery**: Locates Docker Compose projects
4. **Image Updates**: Pulls latest container images
5. **Container Recreation**: Updates running containers
6. **Health Validation**: Checks container status
7. **Resource Cleanup**: Prunes unused resources

### System Verification Workflow

The verification task validates system state after updates:

1. **Network Connectivity**: Checks local network access
2. **Internet Connectivity**: Verifies external access
3. **Service Status**: Confirms critical services are running
4. **Resource Monitoring**: Checks disk and load after updates
5. **Health Scoring**: Calculates overall health score
6. **Report Generation**: Creates verification report

## Common Usage Scenarios

### Routine Maintenance

For regular system maintenance:

```bash
# Full maintenance on all systems
./labops.sh

# Maintenance with email notifications (configured in labops.conf)
./labops.sh
```

### Health Monitoring

For checking system status without updates:

```bash
# Check health of all systems
./labops.sh --tags healthcheck

# Check health of a problematic server
./labops.sh --tags healthcheck --limit problem-server -vv
```

### Docker Container Updates

For updating Docker containers:

```bash
# Update all Docker containers
./labops.sh --tags docker

# Update Docker on specific host
./labops.sh --tags docker --limit docker-host

# Update with verbose output
./labops.sh --tags docker -vv
```

### System Updates

For OS and package updates:

```bash
# Update all Linux systems
./labops.sh --tags system --limit linux

# Update Ubuntu systems only
./labops.sh --tags system --limit ubuntu
```

### Maintenance with Selected Operations

For partial maintenance operations:

```bash
# Update systems, but not Docker
./labops.sh --tags "healthcheck,system,verify"

# Only update and verify Docker containers
./labops.sh --tags "docker,verify"
```

## Automation with Cron

### Schedule Daily Health Checks

```cron
# Daily health check at 7 AM
0 7 * * * /path/to/labops/labops.sh --no-password --tags healthcheck > /path/to/labops/logs/healthcheck.log 2>&1
```

### Schedule Weekly Maintenance

```cron
# Full maintenance Sunday at 2 AM
0 2 * * 0 /path/to/labops/labops.sh --no-password > /path/to/labops/logs/maintenance.log 2>&1
```

### Schedule Docker Updates

```cron
# Update Docker containers Wednesday at 3 AM
0 3 * * 3 /path/to/labops/labops.sh --no-password --tags docker > /path/to/labops/logs/docker.log 2>&1
```

## Working with Logs

LabOps automatically generates detailed logs for each run:

```bash
# View the latest log file
ls -lt logs/ | head -2
cat logs/labops_20250321_120000.log

# Search logs for errors
grep -i error logs/*.log

# Find failed operations
grep -i "failed\|error\|critical" logs/*.log

# Monitor a running operation
tail -f logs/$(ls -t logs/ | head -1)
```

## Customizing Behavior

### Controlling Reboots

Configure reboot behavior in your inventory:

```yml
# In inventory/inventory.yml
all:
  vars:
    # Set to false to disable automatic reboots
    reboot_on_kernel_update: true
    reboot_timeout: 300
    post_reboot_delay: 30
```

### Managing Docker Containers

Configure Docker settings:

```yml
all:
  vars:
    # Docker configuration
    default_docker_path: /opt/homelab
    docker_prune_volumes: false
```

### Critical Services Monitoring

Define which services are considered critical:

```yml
ubuntu:
  vars:
    critical_services:
      - ssh
      - docker
      - nginx
      - mysql
```

## Advanced Examples

### Custom Maintenance Script

Create a custom maintenance script:

```bash
#!/bin/bash
# Custom weekend maintenance script

# Update Docker containers on Friday
if [ $(date +%u) -eq 5 ]; then
  ./labops.sh --tags docker --no-password
fi

# Full system update on Saturday
if [ $(date +%u) -eq 6 ]; then
  ./labops.sh --tags system --no-password
fi

# Health check on Sunday
if [ $(date +%u) -eq 7 ]; then
  ./labops.sh --tags healthcheck --no-password
fi
```

### Conditional Maintenance

Create a script that performs maintenance based on conditions:

```bash
#!/bin/bash
# Conditional maintenance

# Check disk usage first
./labops.sh --tags healthcheck --no-password

# If health check passes, run full maintenance
if [ $? -eq 0 ]; then
  echo "Health check passed, running maintenance"
  ./labops.sh --no-password
else
  echo "Health check failed, sending notification only"
  # Custom notification command here
fi
```

## Best Practices

1. **Regular Health Checks**: Run health checks daily to catch issues early
2. **Staggered Updates**: Schedule updates at different times for different systems
3. **Backup Before Updates**: Create backups before major system updates
4. **Dry Runs**: Use `--check` before major changes
5. **Log Rotation**: Set up log rotation to manage log file growth
6. **SSH Keys**: Use SSH keys instead of passwords for better security
7. **Limit Concurrent Updates**: Update critical systems separately
8. **Monitor First Run**: Watch the first run carefully to identify issues
9. **Start Small**: Begin with a small group of systems before expanding
10. **Consistent Scheduling**: Establish a regular maintenance schedule

## Troubleshooting

### Failed Health Checks

If health checks fail:

1. Check the logs for specific health issues
2. Address disk space or memory problems
3. Use `-vvv` for detailed health check information
4. Run with `--limit` to target the problematic host

### Update Failures

If system updates fail:

1. Check for package conflicts in the logs
2. Verify network connectivity to repositories
3. Try updating problematic packages manually
4. Check for disk space issues

### Docker Issues

If Docker updates fail:

1. Verify Docker service is running
2. Check container logs for specific issues
3. Verify permissions on Docker socket
4. Check network connectivity for image pulls
5. Manually pull a problematic image to troubleshoot

### Notification Issues

If notifications aren't working:

1. Verify notification settings in labops.conf
2. Check SMTP/webhook/Telegram credentials
3. Test notification endpoints directly
4. See the [Notification Guide](notifications.md) for specific troubleshooting

## Next Steps

For further information:

- [Installation Guide](installation.md) - For setup details
- [Notification Guide](notifications.md) - For notification configuration
- Check the project repository for updates and contributions

If you encounter issues not covered in this guide, please open an issue on the project repository.