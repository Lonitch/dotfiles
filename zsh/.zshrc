# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"
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
plugins=(git zsh-history-substring-search zsh-autosuggestions exercism mathphix)

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
toggle_keyboard() {
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
ppt2pdf() {
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

# quarto cli wrapper
qc() {
    local templates_dir="$HOME/.config/quarto/templates"

    # Function to display help message
    show_help() {
        echo "Usage: qc [OPTION] [TEMPLATE_NAME]"
        echo "Options:"
        echo "  --ipt FILE       Specify input file (default: latest modified .qmd file)"
        echo "  --list           List all available templates"
        echo "  --pdf            Convert latest modified .qmd to PDF"
        echo "  --preview        Watch latest modified .qmd"
        echo "  --copy TEMPLATE  Copy the specified template to the current directory"
        echo "  -h               Display this help message"
    }

    # Check for no arguments or -h
    if [ "$#" -eq 0 ] || [ "$1" = "-h" ]; then
        show_help
        return 0
    fi

    if [ "$1" = "--list" ]; then
        echo "Available Quarto templates:"
        ls -1 "$templates_dir"
        return 0
    fi

    local input_file=""
    local template_name=""
    local copy_mode=false
    local pdf_mode=false
    local preview_mode=false

    # Parse arguments
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --ipt)
                shift
                input_file="$1"
                ;;
            --copy)
                copy_mode=true
                shift
                template_name="$1"
                ;;
            --list)
                echo "Available Quarto templates:"
                ls -1 "$templates_dir"
                return 0
                ;;
            --pdf)
                pdf_mode=true
                ;;
            --preview)
                preview_mode=true
                ;;
            *)
                template_name="$1"
                ;;
        esac
        shift
    done

    # If no input file specified, use latest modified .qmd file
    if [ -z "$input_file" ]; then
        input_file=$(ls -t *.qmd 2>/dev/null | head -n1)
        if $copy_mode; then
            if [ -z "$template_name" ]; then
                echo "Error: No template name provided for copy mode."
                show_help
                return 1
            fi
    
            local template_path="$templates_dir/$template_name"
    
            if [ ! -d "$template_path" ]; then
                echo "Template '$template_name' not found in $templates_dir"
                return 1
            fi
    
            echo "Copying template '$template_name' to current directory..."
            cp -R "$template_path"/* .
            echo "Template copied successfully."
        elif [ -z "$input_file" ]; then
            echo "Error: No .qmd file found in the current directory."
            return 1
        elif $pdf_mode; then
            echo "Converting $input_file to PDF..."
            quarto render "$input_file" --to pdf
        elif $preview_mode; then
            echo "Watching $input_file..."
            quarto preview "$input_file"
        else
            echo "No action specified. Use -h for help."
            return 1
        fi
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
# usage
# $ mkvenv myvirtualenv # creates venv under ~/.virtualenvs/
# $ venv myvirtualenv   # activates venv
# $ deactivate          # deactivates venv
# $ rmvenv myvirtualenv # removes venv

export VENV_HOME="$HOME/.virtualenvs"
[[ -d $VENV_HOME ]] || mkdir $VENV_HOME

lsvenv() {
  ls -1 $VENV_HOME
}

venv() {
  if [ $# -eq 0 ]
    then
      echo "Please provide venv name"
    else
      source "$VENV_HOME/$1/bin/activate"
  fi
}

mkvenv() {
  if [ $# -eq 0 ]; then
    echo "Usage: mkvenv <venv_name> [requirements_file]"
    return 1
  fi

  if [ -d "$VENV_HOME/$1" ]; then
    echo "Virtual environment '$1' already exists. Use 'venv $1' to activate it."
    return 1
  fi

  echo "Creating virtual environment '$1'..."
  python3 -m venv "$VENV_HOME/$1"

  echo "Activating virtual environment '$1'..."
  source "$VENV_HOME/$1/bin/activate"

  if [ $# -eq 2 ]; then
    if [ -f "$2" ]; then
      echo "Installing requirements from '$2'..."
      pip install -r "$2"
    else
      echo "Requirements file not found: $2"
    fi
  fi

  echo "Virtual environment '$1' created and activated."
  echo "Use 'deactivate' to exit the virtual environment."
}

rmvenv() {
  if [ $# -eq 0 ]
    then
      echo "Please provide venv name"
    else
      rm -r $VENV_HOME/$1
  fi
}

# marp terminal tool
marpterm() {
    local input_file=""
    local output_format=""
    local preview=true
    local allow_local=false
    local help=false
    local list_themes=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            *.md)
                input_file="$1"
                ;;
            --pdf)
                output_format="--pdf"
                preview=false
                ;;
            --pptx)
                output_format="--pptx"
                preview=false
                ;;
            --local)
                allow_local=true
                ;;
            --list)
                list_themes=true
                ;;
            -h)
                help=true
                ;;
            *)
                echo "Unknown option: $1"
                return 1
                ;;
        esac
        shift
    done

    # Display help
    if $help; then
        echo "Usage: marpterm [filename.md] [--pdf] [--pptx] [--local] [--list] [-h]"
        echo "  filename.md : Input markdown file (optional)"
        echo "  --pdf       : Render to PDF"
        echo "  --pptx      : Render to PPTX"
        echo "  --local     : Allow local file access"
        echo "  --list      : List available theme CSS files"
        echo "  -h          : Display this help message"
        return 0
    fi

    # List theme CSS files
    if $list_themes; then
        echo "Available theme CSS files:"
        ls -1 "$HOME/.config/marp/themes/"*.css 2>/dev/null | sed 's/.*\///' | sed 's/\.css$//'
        return 0
    fi

    # Find latest markdown file if not specified
    if [[ -z "$input_file" ]]; then
        input_file=$(ls -t *.md | head -n1)
        if [[ -z "$input_file" ]]; then
            echo "No markdown file found in the current directory."
            return 1
        fi
    fi

    # Read theme from YAML header
    local yaml_header=$(sed -n '/^---/,/^---/p' "$input_file")
    local marp_theme=$(echo "$yaml_header" | grep 'marp-theme:' | awk '{print $2}')
    local theme=$(echo "$yaml_header" | grep 'theme:' | awk '{print $2}')
    local final_theme=${marp_theme:-$theme}
    local theme_option=""
    if [[ -n "$final_theme" ]]; then
        local theme_file="$HOME/.config/marp/themes/${final_theme}.css"
        if [[ -f "$theme_file" ]]; then
            local local_theme_file="${final_theme}.css"
            cp "$theme_file" "$local_theme_file"
            theme_option="--theme $local_theme_file"
        else
            echo "Warning: Theme file $theme_file not found. Using default theme."
        fi
    fi
    # Construct Marp command
    local marp_cmd="marp --html $theme_option"
    
    if $preview; then
        marp_cmd+=" --watch --preview"
    fi
    
    if $allow_local; then
        marp_cmd+=" --allow-local-files"
    fi
    
    marp_cmd+=" $output_format $input_file"

    # Execute Marp command
    eval $marp_cmd
}
