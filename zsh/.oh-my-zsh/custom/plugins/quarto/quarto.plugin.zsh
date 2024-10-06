# quarto cli wrapper
function qc() {
    local templates_dir="$HOME/.config/quarto/templates"

    # Function to display help message
    show_help() {
        echo "Usage: qc [OPTION] [TEMPLATE_NAME | FILE]"
        echo "Options:"
        echo "  -i|--input FILE : Specify input file (default is latest modified .qmd file)"
        echo "  -l|--list       : List all available templates"
        echo "  --pdf           : Convert input qmd file to PDF"
        echo "  --preview       : Watch input qmd file"
        echo "  --create [FILE] : Create a new qmd by copying the yaml header in the input file"
        echo "  --copy TEMPLATE : Copy the specified template to the current directory"
        echo "  --marp [FILE]   : Render .qmd to a [FILE].md for marp presentation rendering"
        echo "  -h              : Display this help message"
    }

    # Check for no arguments or -h
    if [ "$#" -eq 0 ] || [ "$1" = "-h" ]; then
        show_help
        return 0
    fi

    local input_file=""
    local template_name=""
    local copy_mode=false
    local pdf_mode=false
    local preview_mode=false
    local create_mode=false
    local marp_mode=false
    local new_file=""
    local marp_file=""

    # Parse arguments
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -i|--input)
                shift
                input_file="$1"
                ;;
            -l|--list)
                echo "Available Quarto templates:"
                ls -1 "$templates_dir"
                return 0
                ;;
            --copy)
                copy_mode=true
                shift
                template_name="$1"
                ;;
            --pdf)
                pdf_mode=true
                ;;
            --preview)
                preview_mode=true
                ;;
            --create)
                create_mode=true
                shift
                new_file="$1"
                ;;
            --marp)
                marp_mode=true
                shift
                marp_file="$1"
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
    fi

    if [ -z "$input_file" ] && ! $copy_mode; then
        echo "Error: No .qmd file found."
        return 1
    fi

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
    elif $pdf_mode; then
        echo "Converting $input_file to PDF..."
        quarto render "$input_file" --to pdf
    elif $preview_mode; then
        echo "Watching $input_file..."
        quarto preview "$input_file"
    elif $create_mode; then
        if [ -z "$new_file" ]; then
            echo "Error: No filename provided for create mode."
            show_help
            return 1
        fi
        echo "Creating new file $new_file with YAML header from $input_file..."
        sed -n '/^---$/,/^---$/p; /^#\{1,2\} Intro/,/^#/p' "$input_file" | sed '$d' > "$new_file"
        echo "New file created successfully."
    elif $marp_mode; then
        if [ -z "$marp_file" ]; then
            marp_file="${input_file%.*}.md"
        fi
        echo "Rendering $input_file to $marp_file for marp presentation..."
        python3 $ZSH_CUSTOM/plugins/quarto/marp.py -i $input_file -o $marp_file
        echo "Marp-compatible markdown file created at $marp_file."

    elif [ -z "$input_file" ]; then
        echo "Error: No input file found."
    else
        echo "No action specified. Use -h for help."
        return 1
    fi
}
