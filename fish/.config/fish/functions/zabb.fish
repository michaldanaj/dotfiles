### Zestaw funkcji Zabb dla Fish Shell - wersja All-in-One ###

# --- Funkcje Pomocnicze ---

function _zabb_debug
    if set -q __zabb_debug
        echo $argv
    end
end

function _zabb_dangerous
    set -l strippedWhitespace (string trim -- "$argv")
    if test "$argv" != "$strippedWhitespace"; return 0; end
    if test "$argv" = "-i"; return 0; end
    if test "$argv" = "-s"; return 0; end
    if test "$argv" = "~"; return 0; end
    if string match -q -r '^~.*' -- "$argv"; return 0; end
    return 6
end

function _zabb_get_query
    if set -q ZLUA_SCRIPT; echo "_zlua -e"; return; end
    if command -s zoxide >/dev/null; echo "zoxide query"; return; end
    if command -s fasd >/dev/null; echo "fasd -l -d -1"; return; end
    if type -q z; echo "z -e"; return; end
    echo "zabb: Zoxide/Fasd/Z not found." >&2
    echo "not found"
end

function _zabb_one_letter_abbrevs --argument z_query
    for fragment in (echo {a..z})
        if set -l foundDirectory (eval "$z_query $fragment" 2>/dev/null)
            if test -n "$foundDirectory"
                echo "$fragment $foundDirectory"
            end
        end
    end
end

function _zabb_find_abbrevs --argument directory z_query
    set -l basename (basename "$directory" | string lower)
    set -l baseLength (string length "$basename")
    set -l abbrevs_found
    for length in (seq 1 $baseLength)
        set -l abbrevs
        set -l offsets
        if set -q __zabb_shortest; or set -q __zabb_all
            set offsets (seq 0 (math $baseLength - $length))
        else
            set offsets 0
        end
        for offset in $offsets
            set -l fragment (string sub --start (math $offset + 1) --length $length -- "$basename")
            if _zabb_dangerous "$fragment"; continue; end
            set -l foundDirectory
            if not set foundDirectory (eval "$z_query $fragment" 2>/dev/null); continue; end
            if test -z "$foundDirectory"; continue; end
            set -l realFoundDirectory (realpath "$foundDirectory")
            if test "$realFoundDirectory" = "$directory"
                set -a abbrevs "$fragment"
            end
        end
        if test (count $abbrevs) -gt 0
            set -l abbrevs_found true
            printf "%s\n" $abbrevs | awk '!a[$0]++'
            if not set -q __zabb_all
                return 0
            end
        end
    end
    if set -q abbrevs_found; return 0; end
    echo "No abbreviation found for (basename "$directory")" >&2
    return 1
end

function _zabb_usage
    echo
    echo "USAGE: zabb [<DIRECTORY>]"
    echo
    echo "ARGS:"
    echo "  <DIRECTORY>    Directory to find z abbrevs for (defaults to PWD)"
    echo
    echo "FLAGS:"
    echo "  -s, --shortest   Allow non-contiguous abbreviations"
    echo "  -a, --all        List all contiguous abbreviations"
    echo "  -1, --one-letter List all single letter abbreviation results"
    echo "  -h, --help       Print help"
end

function _zabb_help
    echo 'Find zoxide abbreviations for a directory'
    _zabb_usage
end

# --- Główna funkcja Zabb ---

function zabb --description "Find zoxide abbreviations"
    set -l exit_status 0
    begin
        # POPRAWKA: Usunięto błędny separator `--` przed definicjami flag.
        # Teraz argparse poprawnie interpretuje definicje flag.
        argparse -n zabb --min-args=0 --max-args=1 \
            s/shortest \
            a/all \
            '1/one-letter' \
            d/debug \
            h/help \
            -- $argv
        
        if test $status -ne 0
            _zabb_usage
            set exit_status 3
            return
        end

        if set -q _flag_d; set -g __zabb_debug 1; end
        if set -q _flag_s; set -g __zabb_shortest 1; end
        if set -q _flag_a; set -g __zabb_all 1; set -g __zabb_shortest 1; end

        if set -q _flag_h
            _zabb_help
            set exit_status 0
            return
        end

        set -l z_query (_zabb_get_query)
        if test "$z_query" = "not found"
            set exit_status 2
            return
        end

        if set -q _flag_1
            _zabb_one_letter_abbrevs "$z_query"
            set exit_status $status
            return
        end

        set -l directory
        if test (count $argv) -eq 0
            set directory (realpath "$PWD")
            if test "$z_query" = "_zlua -e"
                set -l zlua_cwd 1
            end
        else
            set directory (realpath "$argv[1]")
            if not test -d "$directory"
                echo "$argv[1] is not a valid, existing directory" >&2
                set exit_status 5
                return
            end
        end

        if set -q zlua_cwd; pushd -q ..; end
        
        _zabb_find_abbrevs "$directory" "$z_query"
        set exit_status $status

        if set -q zlua_cwd; popd -q; end
    end

    set -e __zabb_debug __zabb_shortest __zabb_all
    return $exit_status
end
