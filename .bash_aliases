alias l='ls -l -h -G'
alias ls='ls -C -G'
alias cls='clear'
alias ll='ls -h -C -G -all'

alias prename='perl ~/.localscripts/prename.perl'


alias uppertolowercase='bash ~/.localscripts/uppertolowercase.sh'
alias killproc='bash ~/.localscripts/killproc.sh'
alias loniconnect='bash ~/.localscripts/loni.sh'

printf "the following command will mount the server into the proper spot on this machine \n"
printf "or you can type \n /mountserver.sh \nto execute it.\n"
printf "if you are not user "sidd" you will have to enter your username  as follows \n"
echo mount_smbfs //USERNAME@HSC-TRUCHAS/EFT/Bearer%20Lab/ /Volumes/analysis/mnt/bearerlab/ 
printf "this means that the server folder (Bearer Lab) will be mounted to /Volumes/analysis/mnt/bearerlab \n"
printf "and if you are on this machine (mac pro workstation) it can be accessed via a shortcut \n"
printf "/bearerlab/ -- \n"
printf "instead of needing the full path through Volumes.  \n"


alias gs='git status '
alias ga='git add '
alias gb='git branch '
alias gc='git commit'
alias gd='git diff'
alias go='git checkout '
alias gk='gitk --all&'
alias gx='gitx --all'

export $mywebsite='u54505173@blog.aarongonzales.net'
