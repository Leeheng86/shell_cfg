source ~/.rc/common.sh
#eval `ssh-agent -s`

#alias ls='ls --color=auto'
#alias dir='dir --color=auto'
#alias vdir='vdir --color=auto'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias condaact='conda activate /Users/leeheng_ma/repos/data/minerva/conda/envs/minerva'
alias condadea='conda deactivate'
alias minerva='conda activate minerva'
alias awsinit='export $(aws-creds user -m)'
alias awstest='aws sts get-caller-identity'
alias hive='ssh gw3.di.musta.ch'
alias ghauth="gh auth login --hostname git.musta.ch"
alias airchat="airchat claude -- --permission-mode auto --effort high --model opu"
# and login by hive --emr-cluster homes-shared-prod-ap
# 4_

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

#export JAVA_HOME=$(readlink /usr/bin/java | sed "s:jre/bin/java::")
export PATH=$PATH:~/.local/bin
export PATH="$PATH:$HOME/.rvm/bin"
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$PATH:/opt/airbnb/bin"
export PATH="$PATH:/usr/local/bin/"

export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
export PATH=$JAVA_HOME/bin:$PATH

eval "$(conda "shell.$(basename "${SHELL}")" hook)"

export DATA_DIR=/Users/leeheng_ma/repos/data

# for chronon
export CHRONON_ROOT=/Users/leeheng_ma/repos/ml_models/zipline
export PYTHONPATH=$PYTHONPATH:$CHRONON_ROOT
export CHRONON_ONLINE_CLASS="com.airbnb.bighead.zipline.online.MusselZiplineOnlineImpl"
export CHRONON_ONLINE_ARGS="-Zmussel-host=oyster-kvstore-dispatcher-ml.oyster-kvstore-dispatcher-ml -Zmussel-port=8081"


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# leeheng_ma@leeheng-ma-bigair.ws.airdev.musta.ch:/tmp/
# ./silla_request.sh | python3 -m json.tool
