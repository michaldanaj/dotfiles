#!/bin/sh
src=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
file="$src/../../.config/bookmarks/bookmarks"                # plik w repo
[ -e "$file" ] || file="${XDG_CONFIG_HOME:-$HOME/.config}/bookmarks/bookmarks"

sel=$(wofi --dmenu --prompt "bookmark" < "$file") || exit
target=$(printf '%s' "$sel" | sed 's/ *|.*//')           # separator: " | "

case "$target" in
    ssh\ *)       foot -e $target; exit ;;                   # SSH w terminalu
esac

case "$target" in
    http*|www.*)  xdg-open "$target" ;;
    /*)           [ -d "$target" ] && foot -e yazi "$target" || xdg-open "$target" ;;
    *)            printf '%s' "$target" | wl-copy ;;         # fallback: schowek
esac
