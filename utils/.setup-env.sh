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

# install node, bun, rust, cargo
snap install node
curl -fsSL https://bun.sh/install | bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
echo "node, bun, rust, and cargo installed"

# install lsp for nvim
bun install -g vscode-langservers-extracted @tailwindcss/language-server typescript typescript-language-server prettier eslint_d
cargo install stylua
cargo install typstyle --locked
apt install pipx
pipx ensurepath --global
pipx install jedi-language-server pptx2typ jupytext
echo "LSP for NVim installed"

# install debugger for nvim
wget https://github.com/vadimcn/codelldb/releases/download/v1.10.0/codelldb-x86_64-linux.vsix
unzip codelldb-x86_64-linux.vsix -d codelldb
rm codelldb-x86_64-linux.vsix
echo "codelldb installed"

# install utils: blueman yq fzf ripgrep flameshot sioyek
apt-get install -y blueman ripgrep flameshot
wget https://github.com/ahrm/sioyek/releases/download/v2.0.0/sioyek-release-linux.zip
unzip sioyek-release-linux.zip
cd sioyek-release-linux
mv sioyek /usr/local/bin/
cd ..
rm -rf sioyek-release-linux.zip sioyek-release-linux
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq
chmod +x /usr/bin/yq
echo "blueman, fzf, ripgrep, flameshot, and sioyek installed"

# install quarto, marp, mermaid-cli, rustfmt, presenterm
wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.5.57/quarto-1.5.57-linux-amd64.deb
dpkg -i quarto-1.5.57-linux-amd64.deb
bun install -g @marp-team/marp-cli
bun install -g @mermaid-js/mermaid-cli
rustup component add rustfmt
rustup component add rust-analyzer
cargo install presenterm
echo "quarto, marp, mermaid-cli, rustfmt, and presenterm installed"

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
