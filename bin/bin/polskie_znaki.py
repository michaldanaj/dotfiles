#!/usr/bin/env python3
import sys


def main():
    if len(sys.argv) != 2:
        print("Użycie: ./napraw_kodowanie.py <plik_wejsciowy> <plik_wyjsciowy>")
        sys.exit(1)

    input_filename = sys.argv[1]
    # output_filename = sys.argv[2]
    output_filename = "popr_" + input_filename

    try:
        with open(input_filename, "rb") as file:
            data = file.read()

        # Naprawa kodowania
        if data[0:2] == b"\xcb\x99":
            fixed_data = data.decode("utf8").encode("cp1250").decode("utf-16-le")
        else:
            fixed_data = data.decode("utf8").encode("cp1250").decode("utf8")

        with open(output_filename, "w", encoding="utf8") as file:
            file.write(fixed_data)

        print(f"Plik został zapisany jako: {output_filename}")
    except Exception as e:
        print(f"Błąd: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
