#!/bin/sh
src=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
file="$src/../../.config/bookmarks/bookmarks"                # plik w repo
[ -e "$file" ] || file="${XDG_CONFIG_HOME:-$HOME/.config}/bookmarks/bookmarks"

sel=$(wofi --dmenu --prompt "wpisz bookmark" < "$file") || exit
target=$(printf '%s' "$sel" | sed 's/ *|.*//')           # separator: " | "

sleep 0.15          # daj focusowi wrócić do poprzedniego okna
wtype -- "$target"
