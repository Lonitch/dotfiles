#!/bin/zsh

# Find the id and slave number of the laptop's keyboard
KEYBOARD_INFO=$(xinput list | grep "AT Translated Set 2 keyboard")
KEYBOARD_ID=$(echo "$KEYBOARD_INFO" | grep -oP 'id=\K\d+')
SLAVE_KEYBOARD=$(echo "$KEYBOARD_INFO" | grep -oP 'slave\s+keyboard\s+\(\K\d+')

if [ -z "$KEYBOARD_ID" ] || [ -z "$SLAVE_KEYBOARD" ]; then
    echo "Error: Could not find the laptop keyboard."
    exit 1
fi

# Disable the keyboard
xinput float $KEYBOARD_ID

echo "Laptop keyboard (id=$KEYBOARD_ID) disabled."
echo "To re-enable, use: xinput reattach $KEYBOARD_ID $SLAVE_KEYBOARD"
