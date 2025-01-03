#!/usr/bin/env bash

###############################################################################
# This script sets up your development environment on a fresh Ubuntu-based    #
# system. It detects which packages/commands are already present and only     #
# installs what is missing. It also prompts you after each major step to      #
# proceed or exit if something fails.                                         #
#                                                                             #
# Usage: sudo ./setup_dev_env.sh                                              #
#                                                                             #
# Author:  Lonitch                                                            #
###############################################################################

################################################################################
# Pre-flight Check: Must run with sudo
################################################################################
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo privileges."
  exit 1
fi

################################################################################
# Utility Functions
################################################################################

# A small function to prompt user to continue or exit after each checkpoint.
prompt_to_proceed() {
  echo
  read -rp "Do you want to proceed to the next step? [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY])
      echo "Continuing..."
      ;;
    *)
      echo "Exiting at user request."
      exit 1
      ;;
  esac
  echo
}

# Check if a command exists in PATH. Return 0 if yes, 1 if no.
is_command_installed() {
  command -v "$1" &>/dev/null
}

# Check if an apt package is installed by dpkg-query. Return 0 if yes, 1 if no.
is_apt_package_installed() {
  dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"
}

# Attempt to install an apt package if not installed.
install_apt_package() {
  local pkg="$1"
  if ! is_apt_package_installed "$pkg"; then
    echo "Installing missing apt package: $pkg"
    apt-get install -y "$pkg"
    if ! is_apt_package_installed "$pkg"; then
      echo "Failed to install $pkg."
      FAILED_STEPS+=("$pkg")
    else
      echo "Successfully installed $pkg."
    fi
  else
    echo "Already installed: $pkg"
  fi
}

# Attempt to install a snap package if not installed
install_snap_package() {
  local pkg="$1"
  local opts="$2"   # e.g. --classic
  if ! snap list | awk '{print $1}' | grep -q "^$pkg$"; then
    echo "Installing missing snap package: $pkg $opts"
    snap install "$pkg" $opts --classic
    # Quick check
    if ! snap list | awk '{print $1}' | grep -q "^$pkg$"; then
      echo "Failed to install snap package $pkg."
      FAILED_STEPS+=("$pkg (snap)")
    else
      echo "Successfully installed snap package: $pkg."
    fi
  else
    echo "Already installed snap package: $pkg"
  fi
}

# Print a short report of which apt or snap packages are *already* installed 
# and which ones are missing. This helps the user see a summary at the beginning.
report_apt_packages() {
  echo "Checking apt packages..."
  for pkg in "${APT_PACKAGES[@]}"; do
    if is_apt_package_installed "$pkg"; then
      echo "  [Installed] $pkg"
    else
      echo "  [Missing]   $pkg"
    fi
  done
  echo
}

report_snap_packages() {
  echo "Checking snap packages..."
  for pkg_info in "${SNAP_PACKAGES[@]}"; do
    # pkg_info can be "nvim:--classic" or just "node"
    # Let's parse it
    local pkg
    local opts
    IFS=':' read -r pkg opts <<< "$pkg_info"

    if snap list | awk '{print $1}' | grep -q "^$pkg$"; then
      echo "  [Installed] $pkg"
    else
      echo "  [Missing]   $pkg"
    fi
  done
  echo
}

################################################################################
# Define the packages to be installed here (APT and SNAP).
# This allows easy future additions. Just add packages in the arrays.
################################################################################

APT_PACKAGES=(
  # For building from source, compilers, etc.
  build-essential
  bison
  # For git
  git
  # For stow
  stow
  # For fcitx5
  fcitx5
  fcitx5-chinese-addons
  im-config
  xinput
  # For magick
  luajit
  libmagickwand-dev
  libgraphicsmagick1-dev
  luarocks
  # For LSP (pipx, python-based)
  pipx
  # For other utils
  blueman
  ripgrep
  flameshot
  # i3wm
  i3
  # Dependencies for building picom
  libxext-dev
  libxcb1-dev
  libxcb-damage0-dev
  libxcb-xfixes0-dev
  libxcb-shape0-dev
  libxcb-render-util0-dev
  libxcb-render0-dev
  libxcb-randr0-dev
  libxcb-composite0-dev
  libxcb-image0-dev
  libxcb-present-dev
  libxcb-xinerama0-dev
  libxcb-glx0-dev
  libpixman-1-dev
  libdbus-1-dev
  libconfig-dev
  libgl1-mesa-dev
  libpcre2-dev
  libpcre3-dev
  libevdev-dev
  uthash-dev
  libev-dev
  libx11-xcb-dev
)

SNAP_PACKAGES=(
  "nvim:--classic"
  "firefox"
  "node"
)

################################################################################
# INITIAL REPORT
################################################################################

# Print initial info
echo "You're about to embark on a long journey ahead..."
echo "Below is what is already installed vs. what will be installed."

report_apt_packages
report_snap_packages

echo "Will install or update missing packages above. Continue? (y/N)"
read -r proceed
if [[ "$proceed" != "y" && "$proceed" != "Y" ]]; then
  echo "Exiting."
  exit 1
fi

################################################################################
# GLOBAL TRACKER FOR FAILED STEPS
################################################################################
FAILED_STEPS=()

################################################################################
# STEP 1: Update & Install APT Packages
################################################################################
echo
echo "=== STEP 1: Installing APT Packages ==="
apt-get update -y
for pkg in "${APT_PACKAGES[@]}"; do
  install_apt_package "$pkg"
done

# Checkpoint
echo
if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
  echo "The following APT installs failed: ${FAILED_STEPS[*]}"
fi
prompt_to_proceed

################################################################################
# STEP 2: Install/Check Snap Packages
################################################################################
echo
echo "=== STEP 2: Installing Snap Packages ==="
for pkg_info in "${SNAP_PACKAGES[@]}"; do
  # pkg_info can be "nvim:--classic" or just "node"
  # Let's parse it
  IFS=':' read -r pkg opts <<< "$pkg_info"
  install_snap_package "$pkg" "$opts"
done

# Checkpoint
echo
if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
  echo "The following steps have failed so far: ${FAILED_STEPS[*]}"
fi
prompt_to_proceed

################################################################################
# STEP 3: Install or Setup Zsh, Oh-My-Zsh, Kitty
################################################################################
echo "=== STEP 3: ZSH / OH-MY-ZSH / KITTY ==="

install_zsh_and_oh_my_zsh() {
  if ! is_command_installed zsh; then
    apt-get update
    apt-get install -y wget curl zsh
    if ! is_command_installed zsh; then
      echo "Failed to install zsh, wget, curl."
      FAILED_STEPS+=("zsh/wget/curl")
    fi
  else
    echo "Already installed: zsh"
  fi

  # Change default shell to zsh if not already
  if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)" "$SUDO_USER"
    echo "Default shell changed to zsh for $SUDO_USER."
  fi

  # Install oh-my-zsh if not present
  if [ ! -d "/home/$SUDO_USER/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    # Use sudo -u to run as the normal user
    sudo -u "$SUDO_USER" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    echo "Already installed: oh-my-zsh"
  fi

  # Install kitty if missing
  if ! is_command_installed kitty; then
    echo "Installing kitty from source..."
    sudo -u "$SUDO_USER" -H bash -c "curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin"
  else
    echo "Already installed: kitty"
  fi
}

install_zsh_and_oh_my_zsh

# Set kitty as default terminal
if [ -f "/home/$SUDO_USER/.local/kitty.app/bin/kitty" ]; then
  update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "/home/$SUDO_USER/.local/kitty.app/bin/kitty" 50
  echo "Kitty set as default x-terminal-emulator."
else
  echo "Kitty binary not found; skipping update-alternatives."
fi

echo "Zsh, oh-my-zsh, and kitty step complete."

# Checkpoint
echo
if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
  echo "Failures so far: ${FAILED_STEPS[*]}"
fi
prompt_to_proceed

################################################################################
# STEP 4: Install Tmux from source and Rust/Cargo
################################################################################
echo "=== STEP 4: Tmux ==="
if ! is_command_installed tmux; then
  install_apt_package "libevent-dev"
  git clone https://github.com/tmux/tmux.git tmux_src_temp
  cd tmux_src_temp || exit 1
  sh autogen.sh
  ./configure
  make && make install
  cd ..
  rm -rf tmux_src_temp
  # Check
  if ! is_command_installed tmux; then
    echo "Failed to install tmux from source."
    FAILED_STEPS+=("tmux")
  else
    echo "tmux installed successfully."
  fi
else
  echo "Already installed: tmux"
fi

if ! is_command_installed cargo; then
  echo "Installing Rust toolchain using rustup..."
  sudo -u "$SUDO_USER" -H bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"

  # Check whether cargo is now installed
  if ! is_command_installed cargo; then
    echo "Failed to install Rust and cargo."
    FAILED_STEPS+=("rust-cargo")
  else
    echo "Rust and cargo installed successfully."
    echo "Note: You may need to source ~/.cargo/env in your shell or reload your terminal."
  fi
else
  echo "Already installed: cargo"
fi

# (Optional) Install some Cargo-based tools
if is_command_installed cargo; then
  echo "Installing some useful cargo utilities..."
  cargo install stylua
  cargo install typstyle --locked
  # etc.
fi

# Checkpoint
echo
if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
  echo "Failures so far: ${FAILED_STEPS[*]}"
fi
prompt_to_proceed

################################################################################
# STEP 5: Additional Luarocks installs & LSP stuff
################################################################################
echo "=== STEP 5: Magick via Luarocks and LSP-related Tools ==="

# magick
if ! luarocks list --porcelain | grep -q '^magick'; then
  echo "Installing Lua magick..."
  luarocks install magick
  if ! luarocks list --porcelain | grep -q '^magick'; then
    echo "Failed to install magick via luarocks."
    FAILED_STEPS+=("magick-luarocks")
  else
    echo "Lua magick installed successfully."
  fi
else
  echo "Lua magick is already installed via luarocks."
fi

# Node-based LSP
echo "Installing node-based global packages (bun + LSP servers)..."
if ! is_command_installed bun; then
  echo "It appears bun is not installed. Attempting installation again..."
  # Re-run Bun installer
  sudo -u "$SUDO_USER" -H bash -c "curl -fsSL https://bun.sh/install | bash"
  # You may need to source .bashrc or .zshrc afterwards for $HOME/.bun/bin to be in PATH
fi

if is_command_installed bun; then
  echo "Installing LSP servers with bun..."
  sudo -u "$SUDO_USER" bun install -g \
    vscode-langservers-extracted \
    @tailwindcss/language-server \
    typescript \
    typescript-language-server \
    prettier \
    eslint_d
else
  echo "Bun is still not found. Skipping LSP servers from bun."
  FAILED_STEPS+=("bun-lsp")
fi

# cargo-based installs
if is_command_installed cargo; then
  echo "Installing cargo-based tools..."
  cargo install stylua
  cargo install typstyle --locked
else
  echo "Cargo not found. Skipping cargo-based tools."
  FAILED_STEPS+=("cargo-lsp-tools")
fi

# pipx-based
if is_command_installed pipx; then
  pipx ensurepath
  # Force shell rehash might be needed
  pipx install jedi-language-server
  pipx install pptx2typ
  pipx install jupytext
else
  echo "pipx not found. Skipping pipx-based tools."
  FAILED_STEPS+=("pipx-lsp-tools")
fi

echo "Step 5 complete."

# Checkpoint
echo
if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
  echo "Failures so far: ${FAILED_STEPS[*]}"
fi
prompt_to_proceed

################################################################################
# STEP 6: Install codelldb (debugger for nvim)
################################################################################
echo "=== STEP 6: codelldb Debugger ==="
if [ ! -d "codelldb" ]; then
  wget https://github.com/vadimcn/codelldb/releases/download/v1.10.0/codelldb-x86_64-linux.vsix
  unzip codelldb-x86_64-linux.vsix -d codelldb
  rm codelldb-x86_64-linux.vsix
else
  echo "codelldb folder already exists; skipping download."
fi

if [ ! -d "codelldb" ]; then
  echo "Failed to install codelldb."
  FAILED_STEPS+=("codelldb")
else
  echo "codelldb installed (unpacked) successfully."
fi

# Checkpoint
echo
if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
  echo "Failures so far: ${FAILED_STEPS[*]}"
fi
prompt_to_proceed

################################################################################
# STEP 7: Additional utilities (sioyek, fzf, yq)
################################################################################
echo "=== STEP 7: Sioyek, fzf, yq ==="

# Sioyek
if ! is_command_installed sioyek; then
  echo "Installing Sioyek..."
  wget https://github.com/ahrm/sioyek/releases/download/v2.0.0/sioyek-release-linux.zip
  unzip sioyek-release-linux.zip -d sioyek-release-linux
  mv sioyek-release-linux/sioyek /usr/local/bin/
  rm -rf sioyek-release-linux.zip sioyek-release-linux
  if ! is_command_installed sioyek; then
    echo "Failed to install sioyek."
    FAILED_STEPS+=("sioyek")
  else
    echo "Sioyek installed successfully."
  fi
else
  echo "Already installed: sioyek"
fi

# fzf
if ! is_command_installed fzf; then
  echo "Installing fzf..."
  sudo -u "$SUDO_USER" git clone --depth 1 https://github.com/junegunn/fzf.git /home/"$SUDO_USER"/.fzf
  sudo -u "$SUDO_USER" /home/"$SUDO_USER"/.fzf/install --all
  if ! is_command_installed fzf; then
    echo "Failed to install fzf."
    FAILED_STEPS+=("fzf")
  else
    echo "fzf installed successfully."
  fi
else
  echo "Already installed: fzf"
fi

# yq
if ! is_command_installed yq; then
  echo "Installing yq..."
  wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq
  chmod +x /usr/bin/yq
  if ! is_command_installed yq; then
    echo "Failed to install yq."
    FAILED_STEPS+=("yq")
  else
    echo "yq installed successfully."
  fi
else
  echo "Already installed: yq"
fi

echo "Step 7 complete."

# Checkpoint
echo
if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
  echo "Failures so far: ${FAILED_STEPS[*]}"
fi
prompt_to_proceed

################################################################################
# STEP 8: Quarto, Marp, Mermaid, Rustfmt, Presenterm
################################################################################
echo "=== STEP 8: Quarto, Marp, Mermaid, Rustfmt, Presenterm ==="

# Quarto
if ! dpkg-query -W -f='${Status}' quarto 2>/dev/null | grep -q "install ok installed"; then
  echo "Installing Quarto..."
  wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.5.57/quarto-1.5.57-linux-amd64.deb
  dpkg -i quarto-1.5.57-linux-amd64.deb
  rm -f quarto-1.5.57-linux-amd64.deb
  if ! dpkg-query -W -f='${Status}' quarto 2>/dev/null | grep -q "install ok installed"; then
    echo "Failed to install quarto."
    FAILED_STEPS+=("quarto")
  else
    echo "Quarto installed successfully."
  fi
else
  echo "Already installed: Quarto"
fi

# marp, mermaid-cli
if is_command_installed bun; then
  echo "Installing marp and mermaid-cli via bun..."
  sudo -u "$SUDO_USER" bun install -g @marp-team/marp-cli @mermaid-js/mermaid-cli
else
  echo "Bun not found. Skipping marp and mermaid-cli."
  FAILED_STEPS+=("bun-marp-mermaid")
fi

# rustfmt, rust-analyzer, presenterm
if is_command_installed rustup; then
  echo "Installing rustfmt and rust-analyzer..."
  rustup component add rustfmt
  rustup component add rust-analyzer
  echo "Installing presenterm via cargo..."
  cargo install presenterm
else
  echo "Rustup not found. Skipping rustfmt, rust-analyzer, and presenterm."
  FAILED_STEPS+=("rustup-tools")
fi

echo "Step 8 complete."

# Checkpoint
echo
if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
  echo "Failures so far: ${FAILED_STEPS[*]}"
fi
prompt_to_proceed

################################################################################
# STEP 9: Build and Install picom from source
################################################################################
echo "=== STEP 9: Picom ==="
if ! is_command_installed picom; then
  echo "Building picom from source..."
  git clone https://github.com/yshui/picom.git picom_src_temp
  cd picom_src_temp || exit 1
  git submodule update --init --recursive
  meson --buildtype=release . build
  ninja -C build
  ninja -C build install
  cd ..
  rm -rf picom_src_temp
  if ! is_command_installed picom; then
    echo "Failed to install picom from source."
    FAILED_STEPS+=("picom")
  else
    echo "picom installed successfully."
  fi
else
  echo "Already installed: picom"
fi

# Checkpoint
echo
if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
  echo "Failures so far: ${FAILED_STEPS[*]}"
fi
prompt_to_proceed

################################################################################
# STEP 10: Dotfiles & Stow
################################################################################
echo "=== STEP 10: Dotfiles ==="
if [ ! -d "/home/$SUDO_USER/dotfiles" ]; then
  sudo -u "$SUDO_USER" git clone https://github.com/Lonitch/dotfiles.git "/home/$SUDO_USER/dotfiles"
else
  echo "dotfiles repo already cloned."
fi

if [ -d "/home/$SUDO_USER/dotfiles" ]; then
  cd "/home/$SUDO_USER/dotfiles" || exit 1
  for dir in */; do
    stow -v "${dir%/}"
  done
  cd "/home/$SUDO_USER"
  echo "Dotfiles stowed successfully."
else
  echo "dotfiles folder not found. Skipping stow."
  FAILED_STEPS+=("dotfiles")
fi

################################################################################
# Final Output
################################################################################
echo
echo "All steps completed."
if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
  echo "Some steps encountered errors/failures:"
  for step in "${FAILED_STEPS[@]}"; do
    echo "  - $step"
  done
  echo
  echo "You may address these issues and re-run the script if needed."
else
  echo "No installation failures detected."
fi

echo
echo "Please restart to make settings fully effective."
echo "Don't forget to set up your SSH on GitHub!"
exit 0
