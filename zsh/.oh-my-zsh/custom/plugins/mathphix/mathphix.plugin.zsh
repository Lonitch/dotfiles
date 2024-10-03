# mathpix.plugin.zsh

# Function: pdf2md
# Description: Converts a PDF file to Markdown using Mathpix API by uploading the file,
# checking the conversion status, and downloading the Markdown result.

pdf2md() {
    # Check if the user provided a PDF file
    if [[ $# -lt 1 ]]; then
        echo "Usage: pdf2md <path_to_pdf> [output_markdown_file]"
        return 1
    fi

    local INPUT_FILE="$1"
    local OUTPUT_FILE="${2:-${INPUT_FILE%.pdf}.md}"
    local MAX_RETRIES=300          # Maximum number of status checks
    local RETRY_INTERVAL=5         # Seconds between retries

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

    # Upload the PDF file
    echo "Uploading '$INPUT_FILE' to Mathpix API..."
    local UPLOAD_RESPONSE
    UPLOAD_RESPONSE=$(curl -s -X POST "https://api.mathpix.com/v3/pdf" \
        -H "app_id: $MATHPIX_APP_ID" \
        -H "app_key: $MATHPIX_APP_KEY" \
        -F "file=@$INPUT_FILE" \
        -F 'options_json={"conversion_formats": {"md": true}, "math_inline_delimiters": ["$", "$"], "rm_spaces": true}')

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

    # Check if the download was successful by verifying if the file is not empty
    if [[ -z "$DOWNLOAD_RESPONSE" ]]; then
        echo "Error: Failed to download the Markdown content."
        return 1
    fi

    # Save the Markdown content to the output file
    echo "$DOWNLOAD_RESPONSE" > "$OUTPUT_FILE"

    echo "Conversion successful! Markdown saved to '$OUTPUT_FILE'."
}
