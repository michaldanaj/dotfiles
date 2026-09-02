#!/bin/bash

# Default values
INPUT_PDF=""
OUTPUT_NAME="output"
DUPLEX=false
PAGE_NUMBERS=false
TWO_UP=false
LANDSCAPE=false

# Function to display usage
usage() {
    echo "Usage: $0 -i <input.pdf> [-o <output_name>] [-d] [-n] [-t] [-l]"
    echo "  -i <input.pdf>:  Input PDF file."
    echo "  -o <output_name>:  Base name for output file(s) (without extension). Default: output"
    echo "  -d: Prepare for manual duplex printing (creates _odd.pdf and _even.pdf files)."
    echo "  -n:  Add page numbers to the document."
    echo "  -t:  2 pages per sheet (2-up)."
    echo "  -l: Landscape orientation for the final output."
    exit 1
}

# Parse command-line options
while getopts "i:o:dntl" opt; do
    case ${opt} in
        i) INPUT_PDF=$OPTARG ;;
        o) OUTPUT_NAME=$OPTARG ;;
        d) DUPLEX=true ;;
        n) PAGE_NUMBERS=true ;;
        t) TWO_UP=true ;;
        l) LANDSCAPE=true ;;
        *) usage ;;
    esac
done

# Check if input PDF is provided
if [ -z "$INPUT_PDF" ]; then
    echo "Error: Input PDF file (-i) is required."
    usage
fi

# Check if input PDF exists
if [ ! -f "$INPUT_PDF" ]; then
    echo "Error: Input PDF file '$INPUT_PDF' not found."
    exit 1
fi

echo "Input PDF: $INPUT_PDF"
echo "Output Name: $OUTPUT_NAME"
echo "Duplex: $DUPLEX"
echo "Page Numbers: $PAGE_NUMBERS"
echo "Two Up: $TWO_UP"
echo "Landscape: $LANDSCAPE"

# --- Dependency Checks ---
# pdfjam is always needed for A4 normalization or 2-up processing.
if ! command -v pdfjam &> /dev/null; then
    echo "Error: pdfjam is not installed. It is required for this script."
    exit 1
fi

# Duplex printing requires pdftk, pdfinfo, and pdflatex.
if $DUPLEX; then
    if ! command -v pdftk &> /dev/null; then
        echo "Error: pdftk is not installed. It is required for the duplex (-d) functionality."
        exit 1
    fi
    if ! command -v pdfinfo &> /dev/null; then
        echo "Error: pdfinfo is not installed (part of poppler-utils). It is required for the duplex (-d) functionality."
        exit 1
    fi
    if ! command -v pdflatex &> /dev/null; then
        echo "Error: pdflatex is not installed (part of a TeX/LaTeX distribution). It is required for the duplex (-d) functionality."
        exit 1
    fi
fi

# Temporary file for intermediate PDF processing
TEMP_PDF_1="/tmp/${OUTPUT_NAME}_temp_1.pdf"
CURRENT_PDF="$INPUT_PDF"

# 2. If -t option is set, prepare two pages on one.
if $TWO_UP; then
    NUP_OPTIONS=""
    if $LANDSCAPE; then
        # Pages side-by-side in landscape
        NUP_OPTIONS="--nup 2x1 --landscape"
    else
        # Pages one above the other in portrait
        NUP_OPTIONS="--nup 1x2"
    fi
    echo "Applying 2-up printing with options: $NUP_OPTIONS"
    pdfjam "$CURRENT_PDF" $NUP_OPTIONS --outfile "$TEMP_PDF_1"
    if [ $? -ne 0 ]; then
        echo "Error: pdfjam failed during 2-up processing."
        exit 1
    fi
    CURRENT_PDF="$TEMP_PDF_1"
else
    # If not 2-up, ensure the document is processed by pdfjam at least once
    # to potentially normalize it and handle landscape orientation.
    echo "Processing document through pdfjam..."
    
    PDFJAM_OPTIONS=""
    if $LANDSCAPE; then
        echo "Applying landscape orientation."
        PDFJAM_OPTIONS="--landscape"
    fi

    pdfjam "$CURRENT_PDF" $PDFJAM_OPTIONS --outfile "$TEMP_PDF_1"
    if [ $? -ne 0 ]; then
        echo "Error: pdfjam failed during initial processing."
        exit 1
    fi
    CURRENT_PDF="$TEMP_PDF_1"
fi

TEMP_PDF_2="/tmp/${OUTPUT_NAME}_temp_2.pdf"

# 3. If -n option is set, add page numbers.
if $PAGE_NUMBERS; then
    echo "Adding page numbers with increased bottom margin."
    
    # Define a larger bottom margin using the geometry package in a LaTeX preamble.
    # This forces a larger footer area for the page number.
    PREAMBLE='\usepackage[bottom=2.5cm]{geometry}'

    pdfjam "$CURRENT_PDF" --preamble "$PREAMBLE" --outfile "$TEMP_PDF_2" --pagecommand '\thispagestyle{plain}\pagenumbering{arabic}'
    if [ $? -ne 0 ]; then
        echo "Error: pdfjam failed during page numbering."
        exit 1
    fi
    CURRENT_PDF="$TEMP_PDF_2"
fi

TEMP_PDF_3="/tmp/${OUTPUT_NAME}_temp_3.pdf"
TEMP_PDF_ODD_RAW="/tmp/${OUTPUT_NAME}_odd_raw.pdf"
TEMP_PDF_EVEN_RAW="/tmp/${OUTPUT_NAME}_even_raw.pdf"
TEMP_PDF_ODD_REVERSED="/tmp/${OUTPUT_NAME}_odd_reversed.pdf"
TEMP_PDF_EVEN_REVERSED="/tmp/${OUTPUT_NAME}_even_reversed.pdf"

# 4. If -d option is set, prepare for duplex printing
if $DUPLEX; then
    echo "Preparing for manual duplex printing using pdftk."

    # Get page count
    PAGE_COUNT=$(pdfinfo "$CURRENT_PDF" | grep Pages | awk '{print $2}')
    echo "Current PDF page count: $PAGE_COUNT"

    # If odd, add a blank page
    if (( PAGE_COUNT % 2 != 0 )); then
        echo "Page count is odd. Appending a blank page."
        # Create a blank PDF page using pdflatex
        BLANK_TEX_FILE="/tmp/blank_page_${$}.tex"
        BLANK_PAGE_PDF="/tmp/blank_page_${$}.pdf"
        # Using a simple, standard class for wider compatibility
        echo '\documentclass{article}\begin{document}\null\end{document}' > "$BLANK_TEX_FILE"
        
        # Run pdflatex and hide its verbose output
        (cd /tmp && pdflatex -jobname=blank_page_${$} "$BLANK_TEX_FILE" > /dev/null 2>&1)
        if [ $? -ne 0 ]; then
            echo "Error: Failed to create blank page with pdflatex. Check pdflatex installation."
            # Clean up partial files
            rm -f "/tmp/blank_page_${$}.tex" "/tmp/blank_page_${$}.aux" "/tmp/blank_page_${$}.log"
            exit 1
        fi

        # Append blank page to CURRENT_PDF using pdftk
        pdftk "$CURRENT_PDF" "$BLANK_PAGE_PDF" cat output "$TEMP_PDF_3"
        if [ $? -ne 0 ]; then
            echo "Error: pdftk failed appending blank page."
            exit 1
        fi
        CURRENT_PDF="$TEMP_PDF_3"
        PAGE_COUNT=$((PAGE_COUNT + 1))
        echo "New page count after padding: $PAGE_COUNT"
        # Clean up all pdflatex temporary files
        rm -f "$BLANK_PAGE_PDF" "$BLANK_TEX_FILE" "/tmp/blank_page_${$}.aux" "/tmp/blank_page_${$}.log"
    fi

    # Separate odd and even pages using pdftk
    echo "Separating odd and even pages."
    pdftk "$CURRENT_PDF" cat odd output "$TEMP_PDF_ODD_RAW"
    if [ $? -ne 0 ]; then
        echo "Error: pdftk failed separating odd pages."
        exit 1
    fi
    #pdftk "$CURRENT_PDF" cat even output "$TEMP_PDF_EVEN_RAW"
    pdftk "$CURRENT_PDF" cat even output "$TEMP_PDF_EVEN_RAW"
    if [ $? -ne 0 ]; then
        echo "Error: pdftk failed separating even pages."
        exit 1
    fi

    # Reverse odd pages using pdftk
    #echo "Reversing order of odd pages."
    pdftk "$TEMP_PDF_EVEN_RAW" cat end-1 output "$TEMP_PDF_EVEN_REVERSED"
    #pdftk "$TEMP_PDF_ODD_RAW" cat end-1 output "$TEMP_PDF_ODD_REVERSED"
    #if [ $? -ne 0 ]; then
    #    echo "Error: pdftk failed reversing odd pages."
    #    exit 1
    #fi

    # Final outputs for duplex will be $TEMP_PDF_ODD_REVERSED and $TEMP_PDF_EVEN_RAW
fi # Closes the if $DUPLEX block

# Final output
if $DUPLEX; then
    echo "Saving final duplex output to ${OUTPUT_NAME}_1_odd.pdf and ${OUTPUT_NAME}_2_even.pdf"
    #mv "$TEMP_PDF_ODD_REVERSED" "${OUTPUT_NAME}_odd.pdf"
    mv "$TEMP_PDF_ODD_RAW" "${OUTPUT_NAME}_1_odd.pdf"
    mv "$TEMP_PDF_EVEN_REVERSED" "${OUTPUT_NAME}_2_even.pdf"
else
    echo "Saving final output to ${OUTPUT_NAME}.pdf"
    # Only move if CURRENT_PDF is not the original INPUT_PDF to avoid overwriting input
    if [ "$CURRENT_PDF" != "$INPUT_PDF" ]; then
        mv "$CURRENT_PDF" "${OUTPUT_NAME}.pdf"
    else
        # If no operations were performed, just copy the input to the output name
        cp "$INPUT_PDF" "${OUTPUT_NAME}.pdf"
    fi
fi

# Clean up temporary files
echo "Cleaning up temporary files."
# Filter out empty or non-existent paths from rm arguments
TEMP_FILES=("$TEMP_PDF_1" "$TEMP_PDF_2" "$TEMP_PDF_3" "$TEMP_PDF_ODD_RAW" "$TEMP_PDF_EVEN_RAW" "$TEMP_PDF_ODD_REVERSED")
for temp_file in "${TEMP_FILES[@]}"; do
    if [ -f "$temp_file" ]; then
        rm "$temp_file"
    fi
done

echo "Script finished successfully."
