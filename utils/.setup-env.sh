#!/bin/sh

# this script requires sudo privileges to run!!
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo privileges"
    exit 1
fi

echo "You're about to embark on a long journey ahead..."
# make sure C compiler make/yacc/bison are installed
apt-get install -y build-essential bison
echo "C compiler, make, yacc, and bison installed"

# make sure git is installed
apt-get install -y git
echo "Git installed"

# install terminal emulator (kitty) and zsh/oh-my-zsh
install_zsh_and_oh_my_zsh() {
    if ! command -v zsh &> /dev/null; then
        apt-get update
        apt-get install -y wget curl zsh
    fi
        
    chsh -s $(which zsh)

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    if ! command -v kitty &> /dev/null; then
        curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    fi
}

install_zsh_and_oh_my_zsh

# set the default terminal emulator to be kitty
update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator $HOME/.local/kitty.app/bin/kitty 50

# install tmux
git clone https://github.com/tmux/tmux.git
cd tmux
sh autogen.sh
./configure
make && make install
cd $HOME
echo "tmux installed"

# install GNU stow
apt-get install -y stow
echo "GNU stow installed"

# install fcitx5
apt-get install -y fcitx5 fcitx5-chinese-addon im-config xinput
echo "fcitx5 installed"
# run im-config afterwards to choose fcitx(5) as default method
# `stow utils` to set up .xprofile
# restart to use dual input (chn/eng) input

# install magick
apt-get install -y luajit
apt-get install -y libmagickwand-dev libgraphicsmagick1-dev
apt-get install -y luarocks
luarocks install magick
echo "magick installed"

# install nvim and firefox using snap
snap install nvim --classic
snap install firefox
echo "nvim and firefox installed"

# install bun, rust, cargo
curl -fsSL https://bun.sh/install | bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
echo "bun, rust, and cargo installed"

# install lsp for nvim
bun install -g vscode-langservers-extracted @tailwindcss/language-server typescript typescript-language-server prettier eslint_d
cargo install stylua

# install quarto, marp, mermaid-cli, presenterm
wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.5.57/quarto-1.5.57-linux-amd64.deb
dpkg -i quarto-1.5.57-linux-amd64.deb
bun install -g @marp-team/marp-cli
bun install -g @mermaid-js/mermaid-cli
cargo install presenterm
echo "quarto, marp, mermaid-cli, and presenterm installed"

# install i3wm
apt-get install -y i3
echo "i3wm installed"

# install picom
apt-get install -y libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libxcb-glx0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev libpcre2-dev libpcre3-dev libevdev-dev uthash-dev libev-dev libx11-xcb-dev
git clone https://github.com/yshui/picom.git
cd picom
git submodule update --init --recursive
meson --buildtype=release . build
ninja -C build
ninja -C build install
cd $HOME
echo "picom installed"

# copy dotfiles and stow things
git clone https://github.com/Lonitch/dotfiles.git
cd dotfiles
for dir in */; do
    stow -v "${dir%/}"
done

echo "Please restart to make settings working,"
echo "and do not forget to set up your ssh on github!"
