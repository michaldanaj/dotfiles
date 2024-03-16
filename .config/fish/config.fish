if status is-interactive
    # Commands to run in interactive sessions can go here

    # Load fishmarks (http://github.com/techwizrd/fishmarkshttp://github.com/techwizrd/fishmarks)
    source ~/bin/fishmarks/marks.fish

end

alias ls="eza -F --group-directories-first"
alias ll="eza -lF --time-style=long-iso --header  --color=auto\
    --group-directories-first"
alias la="eza -aF --color=auto --group-directories-first"
alias lal="eza -alF --time-style=long-iso --color=auto --group-directories-first"
alias lla="eza -alF --time-style=long-iso --color=auto --group-directories-first"


# Hishtory Config:
export PATH="$PATH:/home/michald/.hishtory"
source /home/michald/.hishtory/config.fish

# Created by `pipx` on 2023-06-15 06:59:53
set PATH $PATH /mnt/wspolny/home/michald/.local/bin

#eza --color=always --oneline --group-directories-first|\
    #    fzf --ansi --color='bg+:8,gutter:0' --no-sort --border --reverse --height 50%

