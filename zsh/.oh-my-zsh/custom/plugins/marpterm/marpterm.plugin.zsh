# marp terminal tool
function marpterm() {
    local input_file=""
    local output_format=""
    local preview=true
    local no_local=false
    local help=false
    local list_themes=false
    local archive=false
    local archive_file=""

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
            --no-local|-nl)
                no_local=true
                ;;
            --list|-l)
                list_themes=true
                ;;
            --help|-h)
                help=true
                ;;
            --archive|-a)
                archive=true
                shift
                archive_file="$1"
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
        echo "  filename.md                   : Input markdown file (latest modified md file by default)"
        echo "  --archive | -a  <archived.md> : Append content of input md to <archived.md>"
        echo "  --pdf                         : Render to PDF"
        echo "  --pptx                        : Render to PPTX"
        echo "  --no-local| -nl               : No Use of Local Files"
        echo "  --list | -l                   : List available theme CSS files"
        echo "  --help | -h                   : Display this help message"
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

    # Archive content if requested
    if $archive; then
        if [[ -z "$archive_file" ]]; then
            echo "Error: No archive file specified."
            return 1
        fi
        
        # Check if archive file exists and ends with "\n---\n"
        if [[ -f "$archive_file" ]]; then
            # check if "\n---\n" exists in the last 15 characters of the archive file
            if ! tail -c 15 "$archive_file" | grep -q $'\n---\n'; then
                echo -e "\n---\n" >> "$archive_file"
            fi
        fi
        
        # Extract content after YAML header
        local content=$(sed -e '1,/^---$/d' "$input_file")
        # Remove all "---" in the content
        # content=$(echo "$content" | sed 's/---//g')
        # Append content to archive file
        echo "$content" >> "$archive_file"
        echo "Content from $input_file has been appended to $archive_file"
        return 0
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
            local input_dir=$(dirname "$input_file")
            local local_theme_file="$input_dir/${final_theme}.css"
            cp "$theme_file" "$local_theme_file"
            theme_option="--theme $local_theme_file"
            echo "Info: Using theme file $theme_file"
        else
            echo "Warning: Theme file $theme_file not found. Using default theme."
        fi
    else
      echo "Warning: Theme was not set in $input_file!"
    fi
    # Construct Marp command
    local marp_cmd="python3 $ZSH_CUSTOM/plugins/marpterm/marpterm.py $theme_option"
    
    if $no_local; then
        marp_cmd+=" --no-local"
    fi
    
    marp_cmd+=" $output_format $input_file"

    # Execute Marp command
    eval $marp_cmd
}
