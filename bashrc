#eval `ssh-agent -s`

alias ls='ls --color=auto'
#alias dir='dir --color=auto'
#alias vdir='vdir --color=auto'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

export CLICOLOR=1
export TERM=xterm-color
export LSCOLORS=Dxfxcxdxbxegedabagacad
# For colourful man pages (CLUG-Wiki style)
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

PS1=" \# [\[\e[32;1m\]\w\[\e[0m\]]\$"

export RUBYOPT=rubygems
set -o vi

parse_git_branch (){
   git name-rev HEAD 2> /dev/null | sed 's#HEAD\ \(.*\)# [\1]#'
}

export JAVA_HOME=$(readlink /usr/bin/java | sed "s:jre/bin/java::")
export PATH=$PATH:~/.local/bin
export PATH="$PATH:$HOME/.rvm/bin"
