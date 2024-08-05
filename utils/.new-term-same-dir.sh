#!/bin/zsh
# Check if xcwd is installed
if command -v xcwd &> /dev/null; then
    # xcwd is installed, use it to launch kitty
    i3-sensible-terminal -d $(xcwd) &
else
    # xcwd is not installed, print a warning and launch kitty in the home directory
    echo "Warning: xcwd is not installed. Launching Kitty in the home directory."
    echo "To install xcwd, use your package manager or visit: https://github.com/schischi/xcwd"
    i3-sensible-terminal &
fi
