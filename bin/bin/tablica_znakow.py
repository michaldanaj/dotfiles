znaki = "ążźćśęółńĄŻŹĆŚĘÓŁŃ"
wyn = [[znak, znak.encode("utf-8").hex()] for znak in znaki]

print("  utf-8 utf-16-le cp1250 iso8859-1 iso8859-2")
for znak in znaki:
    print(
        znak,
        znak.encode("utf-8").hex(),
        znak.encode("utf-16-le").hex(),
        znak.encode("cp1250").hex(),
        znak.encode("iso8859-1", "ignore").hex(),
        znak.encode("iso8859-2").hex(),
    )
print(wyn)
