#!/usr/bin/env zsh

# -------------------------------------------------------------------
# Script: setup-two-github-ssh.sh
# Description: Creates two SSH keys for two separate GitHub accounts,
#              prompting for custom key names if desired.
# Usage: ./setup-two-github-ssh.sh
# -------------------------------------------------------------------

# Prompt for the two GitHub emails
echo -n "Enter email for first GitHub account (e.g., personal@gmail.com): "
read FIRST_EMAIL
echo -n "Enter key file name for first account (leave empty to default): "
read FIRST_KEY_NAME
echo -n "Enter email for second GitHub account (e.g., work@company.com): "
read SECOND_EMAIL
echo -n "Enter key file name for second account (leave empty to default): "
read SECOND_KEY_NAME

# Define default key names if none provided
if [[ -z "$FIRST_KEY_NAME" ]]; then
  FIRST_KEY_NAME="id_github_${FIRST_EMAIL//[^a-zA-Z0-9]/_}"
fi

if [[ -z "$SECOND_KEY_NAME" ]]; then
  SECOND_KEY_NAME="id_github_${SECOND_EMAIL//[^a-zA-Z0-9]/_}"
fi

# Define the paths for the new SSH keys
FIRST_KEY_PATH="$HOME/.ssh/$FIRST_KEY_NAME"
SECOND_KEY_PATH="$HOME/.ssh/$SECOND_KEY_NAME"

# -------------------------------------------------------------------
# Generate SSH keys if they don't exist
# -------------------------------------------------------------------

echo ""
echo "Generating SSH key for the first account ($FIRST_EMAIL) with key name: $FIRST_KEY_NAME"
if [ -f "$FIRST_KEY_PATH" ]; then
    echo "Key $FIRST_KEY_PATH already exists. Skipping generation."
else
    ssh-keygen -t ed25519 -C "$FIRST_EMAIL" -f "$FIRST_KEY_PATH" -N ""
    echo "Key generated at $FIRST_KEY_PATH"
fi

echo ""
echo "Generating SSH key for the second account ($SECOND_EMAIL) with key name: $SECOND_KEY_NAME"
if [ -f "$SECOND_KEY_PATH" ]; then
    echo "Key $SECOND_KEY_PATH already exists. Skipping generation."
else
    ssh-keygen -t ed25519 -C "$SECOND_EMAIL" -f "$SECOND_KEY_PATH" -N ""
    echo "Key generated at $SECOND_KEY_PATH"
fi

# -------------------------------------------------------------------
# Update ~/.ssh/config
# -------------------------------------------------------------------

echo ""
echo "Configuring your ~/.ssh/config ..."

SSH_CONFIG="$HOME/.ssh/config"

# Make sure the file exists
touch "$SSH_CONFIG"

# Backup existing config
cp "$SSH_CONFIG" "${SSH_CONFIG}.bak_$(date +%Y%m%d%H%M%S)"

# Remove old config entries for these keys if they exist
sed -i.bak "/Host github-$FIRST_KEY_NAME/,/IdentityFile $FIRST_KEY_PATH/d" "$SSH_CONFIG"
sed -i.bak "/Host github-$SECOND_KEY_NAME/,/IdentityFile $SECOND_KEY_PATH/d" "$SSH_CONFIG"

# Append new config
{
    echo ""
    echo "# --------------------------------------------------"
    echo "# Configuration for first GitHub account: $FIRST_EMAIL"
    echo "Host github-$FIRST_KEY_NAME"
    echo "  HostName github.com"
    echo "  User git"
    echo "  IdentityFile $FIRST_KEY_PATH"
    echo ""
    echo "# Configuration for second GitHub account: $SECOND_EMAIL"
    echo "Host github-$SECOND_KEY_NAME"
    echo "  HostName github.com"
    echo "  User git"
    echo "  IdentityFile $SECOND_KEY_PATH"
    echo "# --------------------------------------------------"
    echo ""
} >> "$SSH_CONFIG"

# Remove the sed backup files
rm -f "${SSH_CONFIG}.bak"

echo "SSH config updated successfully."

# -------------------------------------------------------------------
# Next steps
# -------------------------------------------------------------------

echo ""
echo "======================================================================="
echo "SSH keys for your two accounts have been created (if they did not exist)!"
echo "1. Add the following public keys to your respective GitHub accounts:"
echo "   - $FIRST_KEY_PATH.pub  (for $FIRST_EMAIL)"
echo "   - $SECOND_KEY_PATH.pub (for $SECOND_EMAIL)"
echo ""
echo "2. To use them in your Git operations, clone your repos using the matching host:"
echo "     git clone git@github-$FIRST_KEY_NAME:\uusername/repo.git"
echo "     git clone git@github-$SECOND_KEY_NAME:\uusername/repo.git"
echo ""
echo "3. If you're pushing or pulling from an existing repo, be sure to update"
echo "   the remote URL to the appropriate 'Host' name from your ~/.ssh/config."
echo "======================================================================="

