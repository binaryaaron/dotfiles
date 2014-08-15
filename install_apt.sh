echo ""
echo "#########"
echo "Downloading and installing git and latex"
echo "#########"
sudo apt-get update -qq
sudo apt-get install git
sudo apt-get install vim
sudo apt-get install texlive-latex-recommended
git clone https://github.com/gmodarelli/solarize.git
echo ""
echo "#########"
echo "Downloading and installing ubuntu tools"
echo "#########"
sudo apt-get install -y -qq ubuntu-dev-tools gdebi-core libapparmor1 psmisc libtool autoconf automake uuid-dev git octave cmake
echo ""
echo "#########"
echo "Downloading and installing R and scientific support
libraries"
echo "#########"
sudo apt-get install r-base r-base-dev
sudo su - \
	-c "R -e \"install.packages('shiny','knitr','ggplot2', 'car','plyr', repos='http://cran.rstudio.com/')\""

echo ""
echo "#########"
echo "Downloading and installing Python development and scientific support
libraries"
echo "#########"
sudo apt-get install -y -qq python-dev python-scipy python-numpy python-matplotlib python-pandas python-nose python-sympy python-scikits.learn

