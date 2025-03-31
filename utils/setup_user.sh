#!/usr/bin/env bash
################################################################################
# setup_user.sh
#
# Must be run as a normal user (no sudo). Installs user-level dev environment:
#   - oh-my-zsh & plugins
#   - kitty
#   - cargo (rustup), bun, codelldb, LSP servers
#   - marp, mermaid, presenterm
#   - user-level installs of sioyek, fzf, yq (in ~/.local/bin)
#
# We have removed the "link/stow dotfiles" section as requested.
# Usage: ./setup_user.sh
################################################################################

if [ "$EUID" -eq 0 ]; then
  echo "ERROR: Do NOT run setup_user.sh with sudo!"
  echo "Please run as a normal user, e.g.:"
  echo "  ./setup_user.sh"
  exit 1
fi

USER_HOME="$HOME"
FAILED_STEPS=()

# ------------------------------------------------------------------------------
# Utility: prompt to proceed
# ------------------------------------------------------------------------------
prompt_to_proceed() {
  echo
  read -rp "Do you want to proceed to the next step? [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY]) echo "Continuing..." ;;
    *) echo "Exiting at user request."; exit 1 ;;
  esac
  echo
}

# ------------------------------------------------------------------------------
# Utility: check if user has command in PATH
# ------------------------------------------------------------------------------
is_user_command_installed() {
  which "$1" &>/dev/null
}

# ------------------------------------------------------------------------------
# Arrays for user-level commands (for reporting)
# ------------------------------------------------------------------------------
USER_TOOLS=(
  "zsh"
  "kitty"
  "cargo"
  "bun"
)

report_user_tools() {
  echo "User-level tools to check/install:"
  for tool in "${USER_TOOLS[@]}"; do
    if is_user_command_installed "$tool"; then
      echo "  [Installed] $tool"
    else
      echo "  [Missing]   $tool"
    fi
  done
  echo
}

# ------------------------------------------------------------------------------
# MAIN
# ------------------------------------------------------------------------------
echo "Setting up user-level environment for $USER (HOME=$USER_HOME)..."
echo
echo "Below is a brief report of user-level tools..."
report_user_tools

read -rp "Press 'y' to continue installing user tools, or 'n' to cancel: " ans
case "$ans" in
  [yY]*) echo "Proceeding..." ;;
  *) echo "Aborted."; exit 1 ;;
esac

echo
echo "=== STEP A: oh-my-zsh and Plugins ==="
if ! is_user_command_installed zsh; then
  echo "WARNING: zsh not found in PATH. Perhaps it's installed system-wide but not in your PATH? Skipping oh-my-zsh..."
else
  # Install oh-my-zsh if not present
  if [ ! -d "$USER_HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    echo "oh-my-zsh is already installed."
  fi

  # zsh plugins
  OMZ_CUSTOM_DIR="$USER_HOME/.oh-my-zsh/custom/plugins"
  mkdir -p "$OMZ_CUSTOM_DIR"

  if [ ! -d "$OMZ_CUSTOM_DIR/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$OMZ_CUSTOM_DIR/zsh-autosuggestions"
  else
    echo "zsh-autosuggestions plugin already installed."
  fi

  if [ ! -d "$OMZ_CUSTOM_DIR/zsh-history-substring-search" ]; then
    echo "Installing zsh-history-substring-search plugin..."
    git clone https://github.com/zsh-users/zsh-history-substring-search "$OMZ_CUSTOM_DIR/zsh-history-substring-search"
  else
    echo "zsh-history-substring-search plugin already installed."
  fi
  
  if [ ! -d "$OMZ_CUSTOM_DIR/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$OMZ_CUSTOM_DIR/zsh-syntax-highlighting"
  else
    echo "zsh-syntax-highlighting plugin already installed."
  fi
  
  # Update .zshrc to enable the plugins if not already enabled
  ZSHRC="$USER_HOME/.zshrc"
  if [ -f "$ZSHRC" ]; then
    echo "Checking if plugins are enabled in .zshrc..."
    
    # Check if plugins line exists
    if grep -q "^plugins=(" "$ZSHRC"; then
      # Check if our plugins are already in the list
      PLUGINS_NEEDED=0
      
      if ! grep -q "plugins=(.*zsh-autosuggestions.*)" "$ZSHRC"; then
        PLUGINS_NEEDED=1
        echo "Need to add zsh-autosuggestions to plugins"
      fi
      
      if ! grep -q "plugins=(.*zsh-history-substring-search.*)" "$ZSHRC"; then
        PLUGINS_NEEDED=1
        echo "Need to add zsh-history-substring-search to plugins"
      fi
      
      if ! grep -q "plugins=(.*zsh-syntax-highlighting.*)" "$ZSHRC"; then
        PLUGINS_NEEDED=1
        echo "Need to add zsh-syntax-highlighting to plugins"
      fi
      
      if [ $PLUGINS_NEEDED -eq 1 ]; then
        echo "Updating plugins in .zshrc..."
        # Create a backup of the original file
        cp "$ZSHRC" "$ZSHRC.bak"
        # Update the plugins line to include our plugins
        sed -i 's/^plugins=(/plugins=(zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting /' "$ZSHRC"
        echo "Updated plugins in .zshrc. Backup saved at $ZSHRC.bak"
      else
        echo "All required plugins are already enabled in .zshrc"
      fi
    else
      echo "No plugins line found in .zshrc, adding one..."
      echo "plugins=(git zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting)" >> "$ZSHRC"
      echo "Added plugins line to .zshrc"
    fi
  else
    echo "Warning: .zshrc file not found. Plugins won't be automatically enabled."
  fi
fi

prompt_to_proceed

echo
echo "=== STEP B: kitty and Commit Mono Nerd Font ==="
if ! is_user_command_installed kitty; then
  echo "Installing Kitty to $USER_HOME/.local/kitty.app..."
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
  # Add kitty to PATH in .zshrc
  if ! grep -q 'kitty.app/bin' "$USER_HOME/.zshrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/kitty.app/bin:$PATH"' >> "$USER_HOME/.zshrc"
  fi
else
  echo "Kitty is already installed."
fi

# Download and install Commit Mono Nerd Font
echo "Installing Commit Mono Nerd Font..."
FONT_DIR="$USER_HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

# Download the font
FONT_ZIP="$USER_HOME/commit-mono-nerd-font.zip"
echo "Downloading Commit Mono Nerd Font..."
curl -L -o "$FONT_ZIP" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/CommitMono.zip"

# Unzip the font to the fonts directory
echo "Extracting font files..."
unzip -o "$FONT_ZIP" -d "$FONT_DIR/CommitMono" "*.ttf"
rm "$FONT_ZIP"

# Update font cache
echo "Updating font cache..."
fc-cache -f

prompt_to_proceed

echo
echo "=== STEP C: fzf, yq (User-level) ==="
mkdir -p "$USER_HOME/.local/bin"

# fzf in ~/.fzf
if ! is_user_command_installed fzf; then
  echo "Installing fzf in ~/.fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$USER_HOME/.fzf"
  # The installer will place fzf binary in ~/.fzf/bin and can update your shell config
  "$USER_HOME/.fzf/install" --key-bindings --completion --update-rc
  if ! is_user_command_installed fzf; then
    echo "Failed to install fzf to PATH"
    FAILED_STEPS+=("fzf")
  else
    echo "fzf installed in ~/.fzf"
  fi
else
  echo "fzf already in PATH."
fi

# yq in ~/.local/bin
if ! is_user_command_installed yq; then
  echo "Installing yq in ~/.local/bin..."
  wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O "$USER_HOME/.local/bin/yq"
  chmod +x "$USER_HOME/.local/bin/yq"
  if ! is_user_command_installed yq; then
    echo "Failed to install yq in ~/.local/bin"
    FAILED_STEPS+=("yq")
  else
    echo "yq installed in ~/.local/bin"
  fi
else
  echo "yq already in PATH."
fi

prompt_to_proceed

echo
echo "=== STEP D: Rust (cargo) and cargo-based tools ==="
if ! is_user_command_installed cargo; then
  echo "Installing Rust via rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  if ! grep -q '.cargo/env' "$USER_HOME/.zshrc" 2>/dev/null; then
    echo '[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"' >> "$USER_HOME/.zshrc"
  fi
  source "$HOME/.cargo/env" 2>/dev/null || true
else
  echo "Cargo is already installed."
fi

# If cargo is present, install cargo-based dev tools
if is_user_command_installed cargo; then
  echo "Installing cargo-based tools: stylua, typstyle, rustfmt, rust-analyzer..."
  cargo install stylua
  cargo install typstyle --locked
  cargo install --locked yazi-fm yazi-cli
  rustup component add rustfmt
  rustup component add rust-analyzer
else
  echo "Cargo not found, skipping cargo-based tools."
fi

prompt_to_proceed

echo
echo "=== STEP E: Bun, plus marp, mermaid-cli, LSP servers ==="
if ! is_user_command_installed bun; then
  echo "Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
fi

if is_user_command_installed bun; then
  # If needed, source ~/.zshrc to ensure ~/.bun/bin is in PATH
  echo "Installing Node-based packages via Bun: LSP servers, marp, mermaid..."
  bun install -g \
    vscode-langservers-extracted \
    @tailwindcss/language-server \
    typescript \
    typescript-language-server \
    prettier \
    eslint_d \
    @marp-team/marp-cli \
    @mermaid-js/mermaid-cli
else
  echo "Bun not found in PATH, skipping LSP, marp, mermaid."
fi

prompt_to_proceed

echo
echo "=== STEP F: codelldb Debugger ==="
if [ ! -d "$USER_HOME/codelldb" ]; then
  echo "Downloading and unpacking codelldb to ~/codelldb..."
  wget https://github.com/vadimcn/codelldb/releases/download/v1.10.0/codelldb-x86_64-linux.vsix -O "$USER_HOME/codelldb-x86_64-linux.vsix"
  unzip "$USER_HOME/codelldb-x86_64-linux.vsix" -d "$USER_HOME/codelldb"
  rm "$USER_HOME/codelldb-x86_64-linux.vsix"
  if [ -d "$USER_HOME/codelldb" ]; then
    echo "codelldb installed in ~/codelldb"
  else
    echo "Failed to unpack codelldb."
    FAILED_STEPS+=("codelldb")
  fi
else
  echo "codelldb folder already exists, skipping download."
fi

echo
echo "=== STEP G: Pip install & node ==="

pkgs=(
  "pynvim"
)

if ! is_user_command_installed pip; then
  echo "pip not found in PATH, skipping Python package installation..."
else
  echo "Installing Python packages via pip..."
  for pkg in "${pkgs[@]}"; do
    pip install "$pkg"
  done
fi

echo "Installing Node.js(22)"
# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
# Download and install Node.js:
nvm install 22

prompt_to_proceed

echo
echo "=== STEP H: Check default shell and terminal ==="

# Check if ZSH is default shell
if [ "$SHELL" = "/bin/zsh" ] || [ "$SHELL" = "/usr/bin/zsh" ]; then
  echo "ZSH is already set as default shell."
else
  echo "ZSH is not set as default shell. Current shell: $SHELL"
  echo "To set ZSH as default shell, run manually:"
  echo "  chsh -s $(which zsh)"
  echo "This requires your password and cannot be automated in this script."
fi

# Check if Kitty is set as default terminal
if [ -n "$XDG_CONFIG_HOME" ]; then
  CONFIG_DIR="$XDG_CONFIG_HOME"
else
  CONFIG_DIR="$HOME/.config"
fi

default_term_found=false
# Check common default terminal configuration locations
if [ -f "$CONFIG_DIR/mimeapps.list" ] && grep -q "kitty" "$CONFIG_DIR/mimeapps.list"; then
  echo "Kitty appears to be set as default terminal in mimeapps.list"
  default_term_found=true
elif [ -f "$HOME/.local/share/applications/mimeapps.list" ] && grep -q "kitty" "$HOME/.local/share/applications/mimeapps.list"; then
  echo "Kitty appears to be set as default terminal in user mimeapps.list"
  default_term_found=true
fi

if ! $default_term_found; then
  echo "Kitty is not detected as default terminal emulator."
  echo "To set Kitty as default terminal, you can run:"
  echo "  xdg-mime default kitty.desktop x-scheme-handler/terminal"
  echo "Or use your desktop environment's settings application."
  
  # Create desktop entry if it doesn't exist
  mkdir -p "$HOME/.local/share/applications"
  desktop_file="$HOME/.local/share/applications/kitty.desktop"
  
  if [ ! -f "$desktop_file" ]; then
    echo "Creating Kitty desktop entry at $desktop_file"
    cat > "$desktop_file" << EOF
[Desktop Entry]
Name=Kitty
GenericName=Terminal Emulator
Comment=Fast, feature-rich, GPU based terminal
Exec=kitty
Terminal=false
Type=Application
Icon=kitty
Categories=System;TerminalEmulator;
MimeType=x-scheme-handler/terminal;
EOF
  fi
fi


echo
echo "User-level setup complete!"
if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
  echo "Some steps failed: ${FAILED_STEPS[*]}"
fi

echo "Please open a new terminal or 'source ~/.zshrc' to load environment variables."
exit 0
