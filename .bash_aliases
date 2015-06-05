alias l='ls -l -h -G'
alias ls='ls -C -G'
alias cls='clear'
alias ll='ls -h -C -G -all'

alias prename='perl ~/dotfiles/prename.perl'


alias gs='git status '
alias ga='git add '
alias gb='git branch '
alias gc='git commit'
alias gd='git diff'
alias go='git checkout '
alias gk='gitk --all&'
alias gx='gitx --all'

if [ -n "$PS1" -a -f /home/site/warehouse/common/config/warehouserc.bash ]; then
      source /home/site/warehouse/common/config/warehouserc.bash
fi

export PATH="$(brew --prefix coreutils)/libexec/gnubin:/usr/local/bin:$PATH"

# export TRTOP=$HOME/site/trsrc-MAINLINE
# export PATH=$PATH:$JAVA_HOME/bin:$TRTOP/scripts
