if status is-interactive
    # Commands to run in interactive sessions can go here

    # Load fishmarks (http://github.com/techwizrd/fishmarkshttp://github.com/techwizrd/fishmarks)
    source ~/bin/fishmarks/marks.fish

    alias ls="eza -F  --color=auto\
        --group-directories-first --icons"
    alias ll="eza -lF --time-style=long-iso --header  --color=auto\
        --group-directories-first --git --icons"
    alias la="eza -aF --color=auto --group-directories-first --git --icons"
    alias lal="eza -alF --time-style=long-iso --color=auto --group-directories-first --git --icons"
    alias lla="eza -alF --time-style=long-iso --color=auto --group-directories-first --git --icons"

    set -g __fish_git_prompt_show_status 1
end
