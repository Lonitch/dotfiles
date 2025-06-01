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
    # Using the simplest method to install oh-my-zsh
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$USER_HOME/.oh-my-zsh"
    
    # Create a .zshrc if it doesn't exist (based on template)
    if [ ! -f "$USER_HOME/.zshrc" ]; then
      cp "$USER_HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$USER_HOME/.zshrc"
      # Set the ZSH path in .zshrc
      sed -i "s|^export ZSH=.*|export ZSH=\"$USER_HOME/.oh-my-zsh\"|" "$USER_HOME/.zshrc"
    fi
  else
    echo "oh-my-zsh directory exists."
    # Make sure oh-my-zsh.sh is present
    if [ ! -f "$USER_HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
      echo "oh-my-zsh.sh missing, repairing installation..."
      rm -rf "$USER_HOME/.oh-my-zsh"
      git clone https://github.com/ohmyzsh/ohmyzsh.git "$USER_HOME/.oh-my-zsh"
    else
      echo "oh-my-zsh is already installed properly."
    fi
  fi

  # ZSH plugins
  # First, verify that oh-my-zsh is properly installed
  if [ ! -d "$USER_HOME/.oh-my-zsh" ]; then
    echo "Error: oh-my-zsh directory not found at $USER_HOME/.oh-my-zsh"
    echo "Plugin installation may fail. Check oh-my-zsh installation."
    FAILED_STEPS+=("oh-my-zsh-verification")
  fi
  
  # Make sure we have the correct custom plugins directory
  # Try multiple possible locations
  OMZ_CUSTOM_DIR=""
  
  if [ -d "$USER_HOME/.oh-my-zsh/custom/plugins" ]; then
    OMZ_CUSTOM_DIR="$USER_HOME/.oh-my-zsh/custom/plugins"
    echo "Found oh-my-zsh plugins directory at: $OMZ_CUSTOM_DIR"
  elif [ -d "$ZSH/custom/plugins" ]; then 
    OMZ_CUSTOM_DIR="$ZSH/custom/plugins"
    echo "Found oh-my-zsh plugins directory using ZSH variable: $OMZ_CUSTOM_DIR"
  elif [ -d "$USER_HOME/.oh-my-zsh/plugins" ]; then
    # Fallback to non-custom plugins dir
    OMZ_CUSTOM_DIR="$USER_HOME/.oh-my-zsh/plugins"
    echo "Using fallback plugins directory: $OMZ_CUSTOM_DIR"
  else
    echo "Warning: Could not find oh-my-zsh plugins directory!"
    echo "Creating default location: $USER_HOME/.oh-my-zsh/custom/plugins"
    OMZ_CUSTOM_DIR="$USER_HOME/.oh-my-zsh/custom/plugins"
  fi
  
  # Create the directory if it doesn't exist
  mkdir -p "$OMZ_CUSTOM_DIR"
  
  # Function to install a plugin
  install_zsh_plugin() {
    local plugin_name="$1"
    local plugin_url="$2"
    local plugin_dir="$OMZ_CUSTOM_DIR/$plugin_name"
    
    if [ ! -d "$plugin_dir" ]; then
      echo "Installing $plugin_name plugin..."
      if git clone "$plugin_url" "$plugin_dir"; then
        echo "$plugin_name installed successfully to $plugin_dir"
      else
        echo "Failed to install $plugin_name plugin!"
        FAILED_STEPS+=("$plugin_name-install")
      fi
    else
      echo "$plugin_name plugin already installed at $plugin_dir"
    fi
  }
  
  # Install each plugin using the function
  install_zsh_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
  install_zsh_plugin "zsh-history-substring-search" "https://github.com/zsh-users/zsh-history-substring-search"
  
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
        sed -i 's/^plugins=(/plugins=(zsh-autosuggestions zsh-history-substring-search /' "$ZSHRC"
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
# Check if Rust is already installed (either cargo, rustc, or rustup)
if ! is_user_command_installed cargo && ! is_user_command_installed rustc && ! is_user_command_installed rustup; then
  echo "Installing Rust via rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  if ! grep -q '.cargo/env' "$USER_HOME/.zshrc" 2>/dev/null; then
    echo '[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"' >> "$USER_HOME/.zshrc"
  fi
  source "$HOME/.cargo/env" 2>/dev/null || true
else
  echo "Rust is already installed in the system."
  read -rp "Do you want to reinstall Rust? [y/N] " reinstall_rust
  case "$reinstall_rust" in
    [yY][eE][sS]|[yY])
      echo "This script should not be run with sudo privileges."
      echo "To reinstall Rust, please follow these steps manually:"
      echo "  1. If installed via system package manager:"
      echo "     sudo apt remove rust cargo rustc   # For Debian/Ubuntu"
      echo "     sudo dnf remove rust cargo rustc   # For Fedora/RHEL"
      echo "     sudo pacman -R rust cargo rustc    # For Arch Linux"
      echo "  2. If installed via rustup:"
      echo "     rustup self uninstall"
      echo "  3. Then run this script again to install Rust via rustup"
      exit 0
      ;;
    *)
      echo "Keeping existing Rust installation."
      ;;
  esac
fi

# If cargo is available, install cargo-based dev tools
if is_user_command_installed cargo; then
  echo "Installing cargo-based tools: stylua, typstyle, rustfmt, rust-analyzer..."
  cargo install stylua
  cargo install typstyle --locked
  cargo install repgrep
  
  # Only run rustup commands if rustup is available
  if is_user_command_installed rustup; then
    rustup component add rustfmt
    rustup component add rust-analyzer
  else
    echo "Note: rustup not found, skipping rustfmt and rust-analyzer installation."
  fi
else
  echo "Cargo not found, skipping cargo-based tools."
fi

prompt_to_proceed

echo
echo "=== STEP E: Bun, plus marp, mermaid-cli, LSP servers ==="
if ! is_user_command_installed bun; then
  echo "Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
  source $HOME/.zshrc
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
echo "=== STEP G: Pip install, uv, & node ==="

pip_pkgs=(
  "pynvim"
  "dvc-ssh"
  "pre-commit"
)

if ! is_user_command_installed pip; then
  echo "pip not found in PATH, skipping Python package installation..."
else
  echo "Installing Python packages via pip..."
  for pkg in "${pip_pkgs[@]}"; do
    pip install "$pkg"
  done
fi

pipx_pkgs=(
  "poetry"
  "pdf2s"
)

if ! is_user_command_installed pipx; then
  echo "pipx not found in PATH, skipping Python standalone installation..."
else
  echo "Installing packages via pipx..."
  for pkg in "${pipx_pkgs[@]}"; do
    pipx install "$pkg"
  done
fi

mkdir $ZSH_CUSTOM/plugins/poetry
poetry completions zsh > $ZSH_CUSTOM/plugins/poetry/_poetry
poetry self add poetry-plugin-shell

echo
echo "Installing uv"
curl -LsSf https://astral.sh/uv/install.sh | sh
# Download ruff python linter
curl -LsSf https://astral.sh/ruff/install.sh | sh

echo
echo "Installing Node.js(22)"
# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
# Download and install Node.js 22:
source $HOME/.zshrc
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
Version=1.0
Name=Kitty
GenericName=Terminal Emulator
Comment=A fast, feature-rich, GPU-based terminal emulator
Exec=$HOME/.local/kitty.app/bin/kitty
Icon=$HOME/.local/kitty.app/lib/kitty/logo/kitty-128.png

Type=Application
Terminal=false
Categories=Utility;TerminalEmulator;System;
StartupWMClass=kitty
MimeType=x-scheme-handler/terminal;
EOF
  fi
  chmod +x $desktop_file
fi


echo
echo "User-level setup complete!"
if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
  echo "Some steps failed: ${FAILED_STEPS[*]}"
fi

echo "To make kitty your default terminal emulator, run:"
echo "sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator $HOME/.local/kitty.app/bin/kitty 50"
echo "Afterwards, please log out to load environment variables."
exit 0
