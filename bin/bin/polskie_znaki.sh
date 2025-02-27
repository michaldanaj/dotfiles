#!/bin/bash
# Konwertuje krzaki z utf-8 na poprawne polskie znaki


# Sprawdź, czy podano plik jako argument
if [ "$#" -ne 1 ]; then
    echo "Użycie: $0 <plik_do_naprawy>"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="naprawiony_$(basename "$INPUT_FILE")"

# Zamiana błędnych znaków na poprawne
sed -e 's/Ä…/ą/g' \
    -e 's/Ä‡/ć/g' \
    -e 's/Ä™/ę/g' \
    -e 's/Ĺ‚/ł/g' \
    -e 's/Ĺ„/ń/g' \
    -e 's/Ăł/ó/g' \
    -e 's/Ĺ›/ś/g' \
    -e 's/Ĺş/ź/g' \
    -e 's/ĹĽ/ż/g' \
    -e 's/Ä„/Ą/g' \
    -e 's/Ä†/Ć/g' \
    -e 's/Ä?/Ę/g' \
    -e 's/Ĺ?/Ł/g' \
    -e 's/Ĺ?/Ń/g' \
    -e 's/Ă?/Ó/g' \
    -e 's/Ĺš/Ś/g' \
    -e 's/Ĺą/Ź/g' \
    -e 's/Ĺť/Ż/g' \
    -e 's/â€“ //g'\
    -e 's/â€ž/"/g'\
    -e 's/â€ť/"/g' "$INPUT_FILE" > "$OUTPUT_FILE"

echo "Naprawiony plik zapisano jako: $OUTPUT_FILE"
