alias l='ls -l -h -G --color'
alias ls='ls -C -G --color'
alias cls='clear'
alias ll='ls -h -C -G -all --color'

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
export PATH="/Users/agonzales/anaconda3/bin:$PATH"
export PATH="/Users/agonzales/.cabal/bin:$PATH"
# export PATH=~/anaconda/bin:"$PATH"
source /opt/homebrew-cask/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc
source /opt/homebrew-cask/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc


# get current branch in git repo
function parse_git_branch() {
        BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
        if [ ! "${BRANCH}" == "" ]
        then
                STAT=`parse_git_dirty`
                echo "[${BRANCH}${STAT}]"
        else
                echo ""
        fi
}

# get current status of git repo
function parse_git_dirty {
        status=`git status 2>&1 | tee`
        dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
        untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
        ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
        newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
        renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
        deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
        bits=''
        if [ "${renamed}" == "0" ]; then
                bits=">${bits}"
        fi
        if [ "${ahead}" == "0" ]; then
                bits="*${bits}"
        fi
        if [ "${newfile}" == "0" ]; then
                bits="+${bits}"
        fi
        if [ "${untracked}" == "0" ]; then
                bits="?${bits}"
        fi
        if [ "${deleted}" == "0" ]; then
                bits="x${bits}"
        fi
        if [ "${dirty}" == "0" ]; then
                bits="!${bits}"
        fi
        if [ ! "${bits}" == "" ]; then
                echo " ${bits}"
        else
                echo ""
        fi
}


export metropolis="sidd@metropolis.alliance.unm.edu"
export galles="sidd@galles.alliance.unm.edu"

alias latexmk='latexmk -xelatex -pvc'
