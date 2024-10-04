# mathpix.plugin.zsh

# Function: pdf2md
# Description: Converts a PDF file to Markdown using Mathpix API by uploading the file,
# checking the conversion status, and downloading the Markdown result.
# Supports -h/--help for help and --page-ranges to specify pages to convert.

pdf2md() {
    # Default values
    local OUTPUT_FILE=""
    local PAGE_RANGE=""
    local MAX_RETRIES=100         # Maximum number of status checks
    local RETRY_INTERVAL=5        # Seconds between retries

    # Function to display help message
    local show_help
    show_help() {
        echo "Usage: pdf2md [options] <path_to_pdf> [output_markdown_file]"
        echo
        echo "Options:"
        echo "  -h, --help               Show this help message and exit."
        echo "  --page-ranges <range>     Specify the page range to convert (e.g., '1-5,7,9-12')."
        echo
        echo "Arguments:"
        echo "  <path_to_pdf>            Path to the input PDF file."
        echo "  [output_markdown_file]   (Optional) Path to save the output Markdown file."
        echo "                           Defaults to the input file name with .md extension."
    }

    # Parse options
    local POSITIONAL=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                return 0
                ;;
            --page-ranges | -pr)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    PAGE_RANGE="$2"
                    shift 2
                else
                    echo "Error: --page-ranges requires a non-empty option argument."
                    return 1
                fi
                ;;
            --page-ranges=* | -pr=*)
                PAGE_RANGE="${1#*=}"
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

    # Check for at least one positional argument (input PDF)
    if [[ $# -lt 1 ]]; then
        echo "Error: Missing required argument <path_to_pdf>."
        show_help
        return 1
    fi

    local INPUT_FILE="$1"
    local OUTPUT_FILE="${2:-${INPUT_FILE%.pdf}.md}"

    # Validate page range format (basic validation)
    if [[ -n "$PAGE_RANGE" ]]; then
        if [[ ! "$PAGE_RANGE" =~ ^([0-9]+(-[0-9]+)?)(,[0-9]+(-[0-9]+)?)*$ ]]; then
            echo "Error: Invalid page range format. Expected format like '1-5,7,9-12'."
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

link2img() {
    local INPUT_FILE=""
    local OUTPUT_DIR="assets"
    local REPLACE=false

    # Function to display help message
    local show_help
    show_help() {
        echo "Usage: link2img [options]"
        echo
        echo "Options:"
        echo "  -h, --help               Show this help message and exit."
        echo "  -i, --input <file>       Specify the input Markdown file."
        echo "  -o, --output <dir>       Specify the output directory for images (default: assets)."
        echo "  -r, --replace            Replace links in the Markdown file with local links."
    }

    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                return 0
                ;;
            -i|--input)
                INPUT_FILE="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -r|--replace)
                REPLACE=true
                shift
                ;;
            *)
                echo "Error: Unknown option: $1"
                show_help
                return 1
                ;;
        esac
    done

    # Check if input file is provided
    if [[ -z "$INPUT_FILE" ]]; then
        echo "Error: Input file is required."
        show_help
        return 1
    fi

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
