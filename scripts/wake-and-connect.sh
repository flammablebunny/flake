#!/usr/bin/env bash
# Wake and connect to PC via Sunshine/Moonlight

CONFIG_FILE="$HOME/.config/agenix/remoteaccess.txt"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found at $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

echo "Sending Wake-on-LAN magic packet to $PC_MAC..."
wakeonlan "$PC_MAC"

echo "Waiting for PC to boot..."
for i in {1..30}; do
    if ping -c 1 -W 1 "$PC_IP" &> /dev/null; then
        echo "PC is online at $PC_IP"
        echo "Starting Moonlight..."
        sleep 3
        moonlight &
        echo "Add the PC in Moonlight using IP: $PC_IP"
        exit 0
    fi
    echo -n "."
    sleep 2
done

echo ""
echo "PC didn't respond in time"
exit 1
