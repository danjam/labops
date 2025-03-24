#!/bin/bash
# LabOps Maintenance Script
# A comprehensive automation framework for managing home lab infrastructure
# Usage: ./labops.sh [options]

# exit if any command fails
set -e

# Script version
VERSION="1.0.0"

# Default values
INVENTORY="inventory/inventory.yml"
PLAYBOOK="playbooks/homelab_maintenance.yml"
ASK_PASS="-kK"
TAGS=""
VERBOSE=""
LOG_DIR="logs"
LOG_FILE="${LOG_DIR}/labops_$(date +%Y-%m-%d_%H-%M-%S).log"
CONFIG_FILE="labops.conf"

# Create logs directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Banner function
function show_banner {
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║                                                        ║"
    echo "║                     LabOps                             ║"
    echo "║            Automated Homelab Management                ║"
    echo "║                    Version $VERSION                      ║"
    echo "║                                                        ║"
    echo "╚════════════════════════════════════════════════════════╝"
}

# Help function
function show_help {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -i, --inventory INVENTORY  Specify inventory file"
    echo "                             (default: $INVENTORY)"
    echo "  -p, --playbook PLAYBOOK    Specify playbook file"
    echo "                             (default: $PLAYBOOK)"
    echo "  -t, --tags TAGS            Specify tags (e.g., system,docker)"
    echo "  -v, --verbose              Increase verbosity (-v, -vv, or -vvv)"
    echo "  -S, --no-password          Don't ask for passwords (use SSH keys)"
    echo "  -l, --limit HOSTS          Limit execution to specified hosts"
    echo "  -c, --check                Run in check mode (dry run)"
    echo "  --list-hosts               List all hosts in the inventory"
    echo "  --version                  Show version information"
    echo "  -h, --help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -t system                     # Run only system update tasks"
    echo "  $0 -l storage                    # Run on storage group only"
    echo ""
    echo "Log files are stored in: $LOG_DIR/"
    exit 0
}

# Version function
function show_version {
    echo "LabOps version $VERSION"
    exit 0
}

# Load config file if it exists
if [ -f "$CONFIG_FILE" ]; then
    echo "⏳ Loading configuration from $CONFIG_FILE"
    source "$CONFIG_FILE"
fi

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--inventory)
            INVENTORY="$2"
            shift 2
            ;;
        -p|--playbook)
            PLAYBOOK="$2"
            shift 2
            ;;
        -t|--tags)
            TAGS="--tags $2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE="-v"
            shift
            ;;
        -vv)
            VERBOSE="-vv"
            shift
            ;;
        -vvv)
            VERBOSE="-vvv"
            shift
            ;;
        -S|--no-password)
            ASK_PASS=""
            shift
            ;;
        -l|--limit)
            LIMIT="--limit $2"
            shift 2
            ;;
        -c|--check)
            CHECK="--check"
            shift
            ;;
        --list-hosts)
            LIST_HOSTS="--list-hosts"
            shift
            ;;
        --version)
            show_version
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            ;;
    esac
done

# Show banner
# show_banner

# Check if inventory and playbook files exist
if [ ! -f "$INVENTORY" ]; then
    echo "❌ Error: Inventory file '$INVENTORY' not found!"
    exit 1
fi

if [ ! -f "$PLAYBOOK" ]; then
    echo "❌ Error: Playbook file '$PLAYBOOK' not found!"
    exit 1
fi

export ANSIBLE_CONFIG="$(pwd)/ansible.cfg"

# If listing hosts, just do that and exit
if [ ! -z "$LIST_HOSTS" ]; then
    echo "📋 Listing hosts in inventory:"
    ansible-playbook $PLAYBOOK -i $INVENTORY $LIST_HOSTS
    exit 0
fi

# Run the playbook and log the output
echo "🚀 Starting LabOps at $(date)"
echo "📋 Command: ansible-playbook $PLAYBOOK $ASK_PASS -i $INVENTORY $TAGS $VERBOSE $LIMIT $CHECK $EXTRA_VARS"
echo "📝 Logging to: $LOG_FILE"

ansible-playbook $PLAYBOOK $ASK_PASS -i $INVENTORY $TAGS $VERBOSE $LIMIT $CHECK $EXTRA_VARS 2>&1 | tee "$LOG_FILE"
ANSIBLE_EXIT_CODE=${PIPESTATUS[0]}

if [ $ANSIBLE_EXIT_CODE -eq 0 ]; then
    echo "✅ LabOps completed successfully at $(date)"
else
    echo "❌ LabOps failed with exit code $ANSIBLE_EXIT_CODE at $(date)"
    echo "📝 Check $LOG_DIR/$LOG_FILE for details"
fi

exit $ANSIBLE_EXIT_CODE
