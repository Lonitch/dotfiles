# mathpix.plugin.zsh

# Function: pdf2md
# Description: Converts a PDF file to Markdown using Mathpix API by uploading the file,
# checking the conversion status, and downloading the Markdown result.
# Usage: pdf2md <path_to_pdf> [options]
# Options:
# -h, --help                        Show help msg 
# -o, --output [output_md_file]     Path to output MD file(default: same as input file)
# -pr, --page-ranges                Specify page ranges to convert (e.g. 2,3,5-6)

function pdf2md() {
    local OUTPUT_FILE=""
    local PAGE_RANGE=""
    local MAX_RETRIES=100         # Maximum number of status checks
    local RETRY_INTERVAL=5        # Seconds between retries

    # Function to display help message
    local show_help
    show_help() {
        echo "Usage: pdf2md <path_to_pdf> [options]"
        echo
        echo "Arguments:"
        echo "  <path_to_pdf>                     Path to the input PDF file."
        echo "Options:"
        echo "  -h, --help                        Show help msg"
        echo "  -o, --output [output_md_file]     Path to output MD file(default: same as input file)"
        echo "  -pr, --page-ranges                Specify page ranges to convert (e.g. 2,3,5-6)"
        echo
    }

    # Parse options
    local POSITIONAL=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                return 0
                ;;
            -o|--output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -pr|--page-ranges)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    PAGE_RANGE="$2"
                    shift 2
                else
                    echo "Error: --page-ranges requires a non-empty option argument."
                    return 1
                fi
                ;;
            -*|--*)
                echo "Error: Unknown option: $1"
                show_help
                return 1
                ;;
            *)
                POSITIONAL+=("$1")
                shift
                ;;
        esac
    done

    # Restore positional parameters
    set -- "${POSITIONAL[@]}"

    # Check for at least one positional argument (input PDF)
    if [[ $# -lt 1 ]]; then
        echo "Error: Missing required argument <path_to_pdf>."
        show_help
        return 1
    fi

    local INPUT_FILE="$1"
    OUTPUT_FILE="${OUTPUT_FILE:-${INPUT_FILE%.pdf}.md}"

    # Validate page range format (basic validation)
    if [[ -n "$PAGE_RANGE" ]]; then
        if [[ ! "$PAGE_RANGE" =~ ^([0-9]+(-[0-9]+)?)(,[0-9]+(-[0-9]+)?)*$ ]]; then
            echo "Error: Invalid page range format. Expected format like '2,3,5-6'."
            return 1
        fi
    fi

    # Check if the input file exists
    if [[ ! -f "$INPUT_FILE" ]]; then
        echo "Error: File '$INPUT_FILE' not found."
        return 1
    fi

    # Ensure the file has a .pdf extension
    if [[ "${INPUT_FILE##*.}" != "pdf" ]]; then
        echo "Error: '$INPUT_FILE' is not a PDF file."
        return 1
    fi
    
    # If input PDF has more than 20 pages, and no page range is set 
    # Wait for confirmation from user to proceed
    if [[ -z "$PAGE_RANGE" ]]; then
        local page_count=$( pdfinfo "$INPUT_FILE" | grep -Po 'Pages:[[:space:]]+\K[[:digit:]]+' )
        if [[ $page_count -gt 20 ]]; then
            echo "Warning: The PDF file has $page_count pages."
            echo "Converting large files may take a long time and consume more API credits."
            read -q "REPLY?Do you want to proceed? (y/n) "
            echo
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                echo "Operation cancelled by user."
                return 1
            fi
        fi
    fi

    # Check for Mathpix credentials
    if [[ -z "$MATHPIX_APP_ID" || -z "$MATHPIX_APP_KEY" ]]; then
        echo "Error: MATHPIX_APP_ID and MATHPIX_APP_KEY environment variables must be set."
        echo "Please add them to your .zshrc or export them in your shell."
        return 1
    fi

    # Construct options_json
    local OPTIONS_JSON='{"conversion_formats": {"md": true}, "math_inline_delimiters": ["$", "$"], "rm_spaces": true}'
    if [[ -n "$PAGE_RANGE" ]]; then
        OPTIONS_JSON=$(jq -n \
            --arg cr "$PAGE_RANGE" \
            --argjson options '{"conversion_formats": {"md": true}, "math_inline_delimiters": ["$", "$"], "rm_spaces": true}' \
            '$options + { "page_ranges": $cr }')
    fi

    # Upload the PDF file
    echo "Uploading '$INPUT_FILE' to Mathpix API..."
    local UPLOAD_RESPONSE
    UPLOAD_RESPONSE=$(curl -s -X POST "https://api.mathpix.com/v3/pdf" \
        -H "app_id: $MATHPIX_APP_ID" \
        -H "app_key: $MATHPIX_APP_KEY" \
        -F "file=@$INPUT_FILE" \
        -F "options_json=$OPTIONS_JSON")

    # Extract pdf_id from the response
    local PDF_ID
    PDF_ID=$(echo "$UPLOAD_RESPONSE" | jq -r '.pdf_id // empty')

    if [[ -z "$PDF_ID" ]]; then
        local ERROR
        ERROR=$(echo "$UPLOAD_RESPONSE" | jq -r '.error // empty')
        echo "Mathpix API Error: ${ERROR:-Unknown error occurred during PDF upload.}"
        return 1
    fi

    echo "Upload successful! PDF ID: $PDF_ID"

    # Initialize retry counter
    local RETRY_COUNT=0
    local STATUS=""

    # Poll the conversion status
    echo "Checking conversion status..."
    while [[ $RETRY_COUNT -lt $MAX_RETRIES ]]; do
        # Fetch the status
        local STATUS_RESPONSE
        STATUS_RESPONSE=$(curl -s -X GET "https://api.mathpix.com/v3/pdf/$PDF_ID" \
            -H "app_id: $MATHPIX_APP_ID" \
            -H "app_key: $MATHPIX_APP_KEY")

        # Extract status
        STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.status // empty')

        if [[ "$STATUS" == "completed" ]]; then
            echo "Conversion completed."
            break
        elif [[ "$STATUS" == "failed" ]]; then
            echo "Error: Conversion failed."
            return 1
        else
            echo "Current status: $STATUS. Retrying in $RETRY_INTERVAL seconds..."
            sleep $RETRY_INTERVAL
            ((RETRY_COUNT++))
        fi
    done

    if [[ "$STATUS" != "completed" ]]; then
        echo "Error: Conversion did not complete within expected time."
        return 1
    fi

    # Download the Markdown file
    echo "Downloading the Markdown file..."
    local DOWNLOAD_RESPONSE
    DOWNLOAD_RESPONSE=$(curl -s -X GET "https://api.mathpix.com/v3/pdf/$PDF_ID.md" \
        -H "app_id: $MATHPIX_APP_ID" \
        -H "app_key: $MATHPIX_APP_KEY")

    # Check if the download was successful by verifying if the response is not empty
    if [[ -z "$DOWNLOAD_RESPONSE" ]]; then
        echo "Error: Failed to download the Markdown content."
        return 1
    fi

    # Save the Markdown content to the output file
    echo "$DOWNLOAD_RESPONSE" > "$OUTPUT_FILE"

    echo "Conversion successful! Markdown saved to '$OUTPUT_FILE'."
}

# Function: link2img
# Description: download images at links in a MD file
# Usage: link2img <input_md_file> [options]
# Options:
#  -h, --help               Show help message and exit.
#  -o, --output <dir>       Specify the output directory for images (default: assets).
#  -r, --replace            Replace links in the Markdown file with local links.

function link2img() {
    local INPUT_FILE=""
    local OUTPUT_DIR="assets"
    local REPLACE=false

    # Function to display help message
    local show_help
    show_help() {
        echo "Usage: link2img <input_md_file> [options]"
        echo
        echo "Arguments:"
        echo "  <input_md_file>           Path to the input Markdown file."
        echo "Options:"
        echo "  -h, --help               Show this help message and exit."
        echo "  -o, --output <dir>       Specify the output directory for images (default: assets)."
        echo "  -r, --replace            Replace links in the Markdown file with local links."
    }

    # Parse options
    local POSITIONAL=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                return 0
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -r|--replace)
                REPLACE=true
                shift
                ;;
            -*|--*)
                echo "Error: Unknown option: $1"
                show_help
                return 1
                ;;
            *)
                POSITIONAL+=("$1")
                shift
                ;;
        esac
    done

    # Restore positional parameters
    set -- "${POSITIONAL[@]}"

    # Check for at least one positional argument (input Markdown file)
    if [[ $# -lt 1 ]]; then
        echo "Error: Missing required argument <input_md_file>."
        show_help
        return 1
    fi

    INPUT_FILE="$1"

    # Check if input file exists
    if [[ ! -f "$INPUT_FILE" ]]; then
        echo "Error: Input file '$INPUT_FILE' not found."
        return 1
    fi

    # Create output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR"

    # Process the Markdown file
    local temp_file=$(mktemp)
    local link_count=0
    local download_count=0

    while IFS= read -r line; do
        if [[ $line =~ "!\[\]\(https:\/\/cdn\.mathpix\.com\/.*\)" ]]; then
            link_count=$((link_count + 1))
            local img_url=$(echo "$line" | grep -oP '(?<=\()https://cdn\.mathpix\.com/[^)]+')
            local img_filename=$(basename "${img_url%%\?*}")
            local img_path="$OUTPUT_DIR/$img_filename"

            # Download the image
            if curl -s -o "$img_path" "$img_url"; then
                download_count=$((download_count + 1))
                echo "Downloaded: $img_filename"

                # Replace the link if -r option is set
                if [[ "$REPLACE" = true ]]; then
                    line=${line//$img_url/$img_path}
                fi
            else
                echo "Failed to download: $img_filename"
            fi
        fi
        echo "$line" >> "$temp_file"
    done < "$INPUT_FILE"

    # Replace the original file if -r option is set
    if [[ "$REPLACE" = true ]]; then
        mv "$temp_file" "$INPUT_FILE"
        echo "Updated links in '$INPUT_FILE'"
    else
        rm "$temp_file"
    fi

    echo "Processed $link_count links, downloaded $download_count images."
}

# Function: md2sec
# Description: divide a markdown file into sections by specifying the markdown title level.
# Divided files are named by following the rule: <md_file>.<section_number>.md
# Section numbers are given by incrementing a counter to give filenames
# Usage: md2sec <md_file> [option]
# Argument:
# <md_file>                       Input MD file
# Options:
# -h, --help                      Show help msg
# -l, --level                     Title level at which the markdown is divided(default:1)
# -o, --output [path_to_folder]   Output folder for storing divided files(default:cwd)

function md2sec() {
    local INPUT_FILE=""
    local LEVEL=1
    local OUTPUT_DIR="."

    # Function to display help message
    local show_help
    show_help() {
        echo "Usage: md2sec <md_file> [options]"
        echo
        echo "Arguments:"
        echo "  <md_file>                       Input MD file"
        echo "Options:"
        echo "  -h, --help                      Show help msg"
        echo "  -l, --level <number>            Title level at which the markdown is divided (default: 1)"
        echo "  -o, --output <path_to_folder>   Output folder for storing divided files (default: current working directory)"
    }

    # Parse options
    local POSITIONAL=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                return 0
                ;;
            -l|--level)
                LEVEL="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -*|--*)
                echo "Error: Unknown option: $1"
                show_help
                return 1
                ;;
            *)
                POSITIONAL+=("$1")
                shift
                ;;
        esac
    done

    # Restore positional parameters
    set -- "${POSITIONAL[@]}"

    # Check for input file argument
    if [[ $# -lt 1 ]]; then
        echo "Error: Missing required argument <md_file>."
        show_help
        return 1
    fi

    INPUT_FILE="$1"

    # Check if input file exists
    if [[ ! -f "$INPUT_FILE" ]]; then
        echo "Error: Input file '$INPUT_FILE' not found."
        return 1
    fi

    # Create output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR"

    # Run the Python script
    python3 $ZSH_CUSTOM/plugins/mathpix/md2sec.py "$INPUT_FILE" --level "$LEVEL" --output "$OUTPUT_DIR"
}
