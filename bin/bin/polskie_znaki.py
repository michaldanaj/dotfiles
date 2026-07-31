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
            print("1")
            print("decode utf8")
            fixed_data = data.decode("utf8")
            print("encode cp1250")
            fixed_data = fixed_data.encode("cp1250").decode("utf-16-le")
            print("decode utf-16-le")
            # fixed_data = fixed_data.decode("utf-16-le")
        else:
            print("2")
            print("decode utf8")
            fixed_data = data.decode("utf8")
            print("encode cp1250")
            fixed_data = fixed_data.encode("cp1250", errors="replace")
            print("decode utf8")
            fixed_data = fixed_data.decode("utf8", errors="replace")

        with open(output_filename, "w", encoding="utf8") as file:
            file.write(fixed_data)

        print(f"Plik został zapisany jako: {output_filename}")
    except Exception as e:
        print(f"Błąd: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
