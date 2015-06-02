ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install git
brew install python3

brew tap caskroom/cask
brew install brew-cask
brew cask install google-chrome
brew cask install dropbox
brew cask install vlc
brew cask install sublime-text

brew update

pip3 install --upgrade setuptools
pip3 install --upgrade pip
pip3 install virtualenv

brew tap samueljohn/python
brew tap homebrew/science
brew install gfortran
brew install gcc
brew install pandoc

pip3 install nose
pip3 install pyparsing
pip3 install python-dateutil
pip3 install pep8
pip3 install numpy
pip3 install scipy
pip3 install matplotlib

pip3 install zeromq # Necessary for pyzmq
pip3 install pyqt # Necessary for the qtconsole
pip3 install pyzmq
pip3 isntall pygments
pip3 install jinja2
pip3 install tornado
pip3 install ipython3
pip3 install jsonschema
pip3 install ipython3-notebook
pip3 install pandas
pip3 install gensim

pip3 install statsmodels
pip3 install shogun
pip3 install pyMC
pip3 install bokeh
pip3 install d3py
pip3 install ggplot
pip3 install matplotlib
pip3 install plotly
pip3 install prettyplotlib
pip3 install seaborn
pip3 install csvkit
pip3 install tables
pip3 install sqlite3
pip3 install theano


# haskell?


# node

brew install node
brew install mysql



# jekyll
gem install jekyll


# R
brew cask install xquartz
brew install R
sudo su -c "R -e \"install.packages('shiny','knitr','ggplot2', 'car','plyr', repos='http://cran.rstudio.com/')\""
