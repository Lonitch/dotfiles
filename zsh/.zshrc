# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/pipx/venvs:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" 

# CUDA ( changes required for diff comp )
# export PATH=/usr/local/cuda-12.6/bin${PATH:+:${PATH}}
# export LD_LIBRARY_PATH=/usr/local/cuda-12.6/lib64\
                         # ${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
# export DISPLAY=:1.0

# Set name of the theme to load 
ZSH_THEME="robbyrussell"
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-history-substring-search zsh-autosuggestions mathpix quarto marpterm)

source $ZSH/oh-my-zsh.sh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# .api_keys should be created separately
# EXAMPLE
# export ANTHROPIC_API_KEY=XXXX
source $HOME/.api_keys

# User configuration
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Set up fzf key bindings and fuzzy completion
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Alias
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# for a full list of active aliases, run `alias`.

alias bat="batcat"

# list sizes of all the folders at pwd
alias doosh="du --max-depth=1 -h | sort -h"

# Fuzzy search for file using bat preview to open it in nvim
alias bvim="nvim \$(fzf -m --preview='bat --color=always {}')"

# use bun to run mermaid cli
alias mmdc="bun run --bun mmdc"

# Application Settings
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/$USER/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/$USER/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/$USER/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/$USER/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# VHACD
export PATH="$HOME/VHACD/build/linux/test:$PATH"
export PATH="$HOME/VHACD/com.unity.robotics.vhacd/Runtime:$PATH"

# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH
# bun completions
[ -s "/home/$USER/.bun/_bun" ] && source "/home/$USER/.bun/_bun"

# fly.io
export FLYCTL_INSTALL="/home/$USER/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

# Turso
export PATH="/home/$USER/.turso:$PATH"
. "$HOME/.cargo/env"

# Snap
export PATH="/snap/bin:$PATH"

# enable legacy openssl provider 
unset NODE_OPTIONS

# toggle the use of laptop keyboard
function toggle_keyboard() {
    # Replace this with your internal keyboard's exact name
    local DEVICE_NAME="AT Translated Set 2 keyboard"
    # Fetch the device ID based on the device name
    local DEVICE_ID
    DEVICE_ID=$(xinput list --id-only "$DEVICE_NAME")
    # Check if the device was found
    if [[ -z "$DEVICE_ID" ]]; then
        echo "Error: Device '$DEVICE_NAME' not found."
        return 1
    fi
    # Get the current state of the device (1 = enabled, 0 = disabled)
    local STATE
    STATE=$(xinput list-props "$DEVICE_ID" | grep "Device Enabled" | awk '{print $NF}')
    # Toggle the device state
    if [[ "$STATE" -eq 1 ]]; then
        xinput disable "$DEVICE_ID"
        echo "Internal keyboard disabled."
    else
        xinput enable "$DEVICE_ID"
        echo "Internal keyboard enabled."
    fi
}
# convert ppt to pdf
function ppt2pdf() {
    if [ $# -eq 0 ]; then
        echo "Usage: ppt2pdf <inputfile.pptx>"
        return 1
    fi

    input_file="$1"
    output_file="${input_file// /_}"
    output_file="${output_file%.*}.pdf"

    if [ ! -f "$input_file" ]; then
        echo "Error: Input file '$input_file' not found."
        return 1
    fi

    soffice --headless --convert-to pdf "$input_file"
    mv "${input_file%.*}.pdf" "$output_file"

    if [ -f "$output_file" ]; then
        echo "Conversion successful. Output file: $output_file"
    else
        echo "Conversion failed."
        return 1
    fi
}


# yazi
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# python3 venv wrapper
export VENV_HOME="$HOME/.virtualenvs"
[[ -d $VENV_HOME ]] || mkdir $VENV_HOME

function venv() {
  local action=""
  local venv_name=""
  local requirements_file=""

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --list|-l)
        action="list"
        shift
        ;;
      --create|-c)
        action="create"
        venv_name="$2"
        shift 2
        ;;
      --remove|-r)
        action="remove"
        venv_name="$2"
        shift 2
        ;;
      --activate|-a)
        action="activate"
        venv_name="$2"
        shift 2
        ;;
      --deactivate|-d)
        action="deactivate"
        shift
        ;;
      -h|--help)
        action="help"
        shift
        ;;
      *)
        requirements_file="$1"
        shift
        ;;
    esac
  done

  case "$action" in
    list)
      ls -1 $VENV_HOME
      ;;
    create)
      if [ -z "$venv_name" ]; then
        echo "Usage: venv --create <venv_name> [requirements_file]"
        return 1
      fi

      if [ -d "$VENV_HOME/$venv_name" ]; then
        echo "Virtual environment '$venv_name' already exists. Use 'venv --activate $venv_name' to activate it."
        return 1
      fi

      echo "Creating virtual environment '$venv_name'..."
      python3 -m venv "$VENV_HOME/$venv_name"

      echo "Activating virtual environment '$venv_name'..."
      source "$VENV_HOME/$venv_name/bin/activate"

      if [ -n "$requirements_file" ]; then
        if [ -f "$requirements_file" ]; then
          echo "Installing requirements from '$requirements_file'..."
          pip install -r "$requirements_file"
        else
          echo "Requirements file not found: $requirements_file"
        fi
      fi

      echo "Virtual environment '$venv_name' created and activated."
      echo "Use 'deactivate' to exit the virtual environment."
      ;;
    remove)
      if [ -z "$venv_name" ]; then
        echo "Usage: venv --remove <venv_name>"
        return 1
      fi
      rm -r "$VENV_HOME/$venv_name"
      echo "Virtual environment '$venv_name' removed."
      ;;
    activate)
      if [ -z "$venv_name" ]; then
        echo "Usage: venv --activate <venv_name>"
        return 1
      fi
      source "$VENV_HOME/$venv_name/bin/activate"
      echo "Virtual environment '$venv_name' activated."
      ;;
    deactivate)
      if command -v deactivate >/dev/null 2>&1; then
        deactivate
        echo "Virtual environment deactivated."
      else
        echo "No active virtual environment to deactivate."
        return 1
      fi
      ;;
    help)
      echo "Usage: venv [--list|-l] [--create|-c <venv_name>] [--remove|-r <venv_name>] [--activate|-a <venv_name>] [--deactivate|-d] [-h|--help]"
      echo "Options:"
      echo "  --list, -l                       List all virtual environments"
      echo "  --create, -c <venv_name> [requirements.txt]  
                                   Create a new virtual environment"
      echo "  --remove, -r                     Remove a virtual environment"
      echo "  --activate, -a                   Activate a virtual environment"
      echo "  --deactivate, -d                 Deactivate the current virtual environment"
      echo "  -h, --help                       Display this help message"
      ;;
    *)
      echo "Usage: venv [--list|-l] [--create|-c <venv_name>] [--remove|-r <venv_name>] [--activate|-a <venv_name>] [--deactivate|-d] [-h|--help]"
      return 1
      ;;
  esac
}

export PATH="$HOME/.local/kitty.app/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
