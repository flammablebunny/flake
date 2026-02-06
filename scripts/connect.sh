#!/usr/bin/env bash
# Connect to PC via Moonlight (PC must be already on)

CONFIG_FILE="$HOME/.config/agenix/remoteaccess.txt"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found at $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

echo "Connecting to PC at $PC_IP..."
moonlight-qt &
