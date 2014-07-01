alias l='ls -l -h -G'
alias ls='ls -C -G'
alias cls='clear'
alias ll='ls -h -C -G -all'

alias prename='perl ~/.localscripts/prename.perl'


alias uppertolowercase='bash ~/.localscripts/uppertolowercase.sh'
alias killproc='bash ~/.localscripts/killproc.sh'
alias loniconnect='bash ~/.localscripts/loni.sh'

echo the following command will mount the server into the proper spot on this machine
echo or you can type /mountserver.sh to execute it. 
echo if you are not user "sidd" you will have to enter your username 
echo mount_smbfs //sidd@HSC-TRUCHAS/EFT/Bearer%20Lab/ /Volumes/analysis/mnt/bearerlab/
echo this means that the server folder (Bearer Lab) will be mounted to /Volumes/analysis/mnt/bearerlab
echo and if you are on this machine (mac pro workstation) it can be accessed via a shortcut
echo -- /bearerlab/ --
echo instead of needing the full path through Volumes. 
