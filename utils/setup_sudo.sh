#!/usr/bin/env bash
################################################################################
# setup_sudo.sh
#
# Must be run with sudo. Installs system-wide packages via apt and snap,
# and builds tmux from source (system-wide).  Sioyek, fzf, yq are *not* here
# (they're now moved to user script). Also includes picom, Quarto, etc.
#
# Usage: sudo ./setup_sudo.sh
################################################################################

if [ "$EUID" -ne 0 ]; then
  echo "ERROR: Please run this script with sudo."
  echo "Example: sudo ./setup_sudo.sh"
  exit 1
fi

# ------------------------------------------------------------------------------
# DEMO: Split $HOME by '/' and get last piece.
#       If you did "sudo su -", $HOME is /root => yields "root"
# ------------------------------------------------------------------------------
user_from_home=$(echo "$HOME" | awk -F'/' '{print $NF}')
echo "Running as root. Last piece of \$HOME is: $user_from_home"
echo

# ------------------------------------------------------------------------------
# Utility: Prompt to proceed
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
# Utility: Check if apt package is installed
# ------------------------------------------------------------------------------
is_apt_installed() {
  dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"
}

# ------------------------------------------------------------------------------
# Utility: Install apt package if missing
# ------------------------------------------------------------------------------
install_apt_package() {
  local pkg="$1"
  if ! is_apt_installed "$pkg"; then
    echo "Installing missing apt package: $pkg"
    apt-get install -y "$pkg"
    if ! is_apt_installed "$pkg"; then
      echo "Failed to install $pkg."
      FAILED_STEPS+=("$pkg")
    else
      echo "Successfully installed $pkg."
    fi
  else
    echo "Already installed: $pkg"
  fi
}

# ------------------------------------------------------------------------------
# Utility: Check if snap package is installed
# ------------------------------------------------------------------------------
is_snap_installed() {
  snap list | awk '{print $1}' | grep -q "^$1$"
}

# ------------------------------------------------------------------------------
# Utility: Install snap package if missing (with optional colon-split)
# ------------------------------------------------------------------------------
install_snap_package() {
  local pkg="$1"
  local opts="$2"
  if ! is_snap_installed "$pkg"; then
    echo "Installing missing snap package: $pkg $opts"
    snap install "$pkg" $opts
    if ! is_snap_installed "$pkg"; then
      echo "Failed to install snap package $pkg."
      FAILED_STEPS+=("$pkg (snap)")
    else
      echo "Successfully installed snap package: $pkg"
    fi
  else
    echo "Already installed snap package: $pkg"
  fi
}

# ------------------------------------------------------------------------------
# Arrays: system-wide apt & snap packages
# ------------------------------------------------------------------------------
APT_PACKAGES=(
  build-essential
  bison
  meson
  cmake
  ninja-build
  git
  stow
  fcitx5
  fcitx5-chinese-addons
  im-config
  xinput
  luajit
  libmagickwand-dev
  libgraphicsmagick1-dev
  luarocks
  pipx
  python3-pip
  blueman
  ripgrep
  flameshot
  i3
  ffmpeg 
  7zip 
  jq 
  poppler-utils 
  fd-find 
  ripgrep 
  zoxide 
  imagemagick
  # Dependencies for building tmux
  libevent-dev
  # Dependencies for building picom
  libconfig-dev 
  libdbus-1-dev 
  libegl-dev 
  libev-dev 
  libgl-dev 
  libepoxy-dev 
  libpcre2-dev 
  libpixman-1-dev 
  libx11-xcb-dev 
  libxcb1-dev 
  libxcb-composite0-dev 
  libxcb-damage0-dev 
  libxcb-glx0-dev 
  libxcb-image0-dev 
  libxcb-present-dev 
  libxcb-randr0-dev 
  libxcb-render0-dev 
  libxcb-render-util0-dev 
  libxcb-shape0-dev 
  libxcb-util-dev 
  libxcb-xfixes0-dev 
  uthash-dev
  # for downloads, building, etc.
  xz-utils
  libssl-dev
  unzip
  wget
  curl
  zsh
  zsh-syntax-highlighting
)

SNAP_PACKAGES=(
  "nvim:--classic"
  "dvc:--classic"
  "firefox"
  "yazi:--classic"
)

# ------------------------------------------------------------------------------
# Summaries
# ------------------------------------------------------------------------------
report_apt_packages() {
  echo "System APT packages required:"
  for pkg in "${APT_PACKAGES[@]}"; do
    if is_apt_installed "$pkg"; then
      echo "  [Installed] $pkg"
    else
      echo "  [Missing]   $pkg"
    fi
  done
  echo
}

report_snap_packages() {
  echo "System Snap packages required:"
  for pkg_info in "${SNAP_PACKAGES[@]}"; do
    IFS=':' read -r pkg opts <<< "$pkg_info"
    if is_snap_installed "$pkg"; then
      echo "  [Installed] $pkg"
    else
      echo "  [Missing]   $pkg"
    fi
  done
  echo
}

# ------------------------------------------------------------------------------
# MAIN
# ------------------------------------------------------------------------------
FAILED_STEPS=()

echo "Below is a brief report of required system packages..."
report_apt_packages
report_snap_packages

read -rp "Press 'y' to continue installing system packages, or 'n' to cancel: " ans
case "$ans" in
  [yY]*) echo "Proceeding..." ;;
  *) echo "Aborted."; exit 1 ;;
esac

echo
echo "=== STEP 1: APT Install ==="
apt-get update -y
for pkg in "${APT_PACKAGES[@]}"; do
  install_apt_package "$pkg"
done

echo
echo "APT packages installed. Failures so far: ${FAILED_STEPS[*]}"
prompt_to_proceed

echo
echo "=== STEP 2: Snap Install ==="
for pkg_info in "${SNAP_PACKAGES[@]}"; do
  IFS=':' read -r pkg opts <<< "$pkg_info"
  install_snap_package "$pkg" "$opts"
done

echo
echo "Snap packages installed. Failures so far: ${FAILED_STEPS[*]}"
prompt_to_proceed

echo
echo "=== STEP 3: Build tmux from source (System-Wide) ==="
if ! command -v tmux &>/dev/null; then
  echo "Building tmux from source..."
  git clone https://github.com/tmux/tmux.git /tmp/tmux_src_temp
  cd /tmp/tmux_src_temp || exit 1
  sh autogen.sh
  ./configure
  make
  # system-wide install
  make install
  cd /tmp
  rm -rf /tmp/tmux_src_temp
  if ! command -v tmux &>/dev/null; then
    echo "Failed to install tmux system-wide."
    FAILED_STEPS+=("tmux")
  else
    echo "tmux installed successfully (system-wide)."
  fi
else
  echo "tmux already installed system-wide."
fi

echo
echo "tmux step done. Failures so far: ${FAILED_STEPS[*]}"
prompt_to_proceed

echo
echo "=== STEP 4: Quarto (system-wide .deb) ==="
if ! dpkg-query -W -f='${Status}' quarto 2>/dev/null | grep -q "install ok installed"; then
  echo "Installing Quarto..."
  wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.5.57/quarto-1.5.57-linux-amd64.deb
  dpkg -i quarto-1.5.57-linux-amd64.deb
  rm -f quarto-1.5.57-linux-amd64.deb
  if ! dpkg-query -W -f='${Status}' quarto 2>/dev/null | grep -q "install ok installed"; then
    echo "Failed to install Quarto."
    FAILED_STEPS+=("quarto")
  else
    echo "Quarto installed successfully."
  fi
else
  echo "Quarto is already installed."
fi

echo
echo "Quarto step done. Failures so far: ${FAILED_STEPS[*]}"
prompt_to_proceed

echo
echo "=== STEP 5: Build picom from source (system-wide) ==="
if ! command -v picom &>/dev/null; then
  echo "Building picom..."
  git clone https://github.com/yshui/picom.git /tmp/picom_src_temp
  cd /tmp/picom_src_temp || exit 1
  git submodule update --init --recursive
  meson --buildtype=release . build
  ninja -C build
  ninja -C build install
  cd /tmp
  rm -rf /tmp/picom_src_temp
  if ! command -v picom &>/dev/null; then
    echo "Failed to install picom system-wide."
    FAILED_STEPS+=("picom")
  else
    echo "picom installed successfully."
  fi
else
  echo "picom is already installed system-wide."
fi

echo
echo "picom step done. Failures so far: ${FAILED_STEPS[*]}"
prompt_to_proceed

echo
echo "System-wide installations complete!"
if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
  echo "Some steps failed: ${FAILED_STEPS[*]}"
else
  echo "No system-level failures detected."
fi

update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator $HOME/.local/kitty.app/bin/kitty 50

echo
echo "Please run \"chsh -s $(which zsh)\" to change default shell and re-login"
echo "Afterwards,you may run './setup_user.sh' (without sudo) to install user-level tools."
exit 0

