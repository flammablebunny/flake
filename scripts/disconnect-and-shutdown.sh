#!/usr/bin/env bash
# Disconnect and shutdown PC

CONFIG_FILE="$HOME/.config/agenix/remoteaccess.txt"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found at $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

echo "Shutting down PC at $PC_IP..."

# Kill any running Moonlight instances
pkill -f moonlight 2>/dev/null

# SSH in and shutdown
ssh ${PC_USER}@${PC_IP} "systemctl poweroff" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "PC shutdown command sent successfully"
else
    echo "Failed to connect to PC"
    exit 1
fi
