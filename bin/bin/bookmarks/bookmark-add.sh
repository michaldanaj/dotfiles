#!/bin/sh
src=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
file="$src/../../.config/bookmarks/bookmarks"                # plik w repo
[ -e "$file" ] || file="${XDG_CONFIG_HOME:-$HOME/.config}/bookmarks/bookmarks"
url=$(wl-paste 2>/dev/null | head -n1)
[ -n "$url" ] || exit 1

# https://landchad.net/ -> landchad.net
url=$(printf '%s' "$url" | sed 's|^https\{0,1\}://||; s|/$||')

# wofi ustawia --prompt jako placeholder GTK, a ten jest niewidoczny gdy pole
# ma focus — kontekst podajemy więc jako wiersz listy, a --exec-search sprawia,
# że Enter zwraca wpisany tekst zamiast tego wiersza
desc=$(printf 'opis dla: %s\n' "$url" | wofi --dmenu --exec-search 2>/dev/null) || exit

printf '%s | %s\n' "$url" "$desc" >> "$file"
