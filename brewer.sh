
brew tap caskroom/cask
brew install brew-cask
brew tap caskroom/fonts
brew install git
brew cask install anaconda
brew cask install spotify
brew cask install iterm2
brew install coreutils
brew cask install wget
wget https://repo.continuum.io/archive/Anaconda3-2.3.0-MacOSX-x86_64.sh
brew install automake
brew install libtool
brew install gawk

brew install cask font-source-code-pro
brew cask install google-chrome
brew cask install dropbox
brew cask install vlc

brew update


brew install gcc
brew install pandoc



brew install node



# jekyll
gem install jekyll


# R
brew cask install xquartz
brew install R
sudo su -c "R -e \"install.packages('shiny','knitr','ggplot2', 'car','plyr', repos='http://cran.rstudio.com/')\""
