Solarize
========

A gnome-terminal tool to use the Solarized theme on Ubuntu.

Dependencies
------------

1. gnome-terminal
2. dircolors

If you don't have them installed on your machine, run this:

    sudo apt-get install dircolors gnome-terminal

Usage
-----

Clone this repository

    git clone https://github.com/gmodarelli/solarize.git ~/.solarized

Make solarize.sh executable

    chmod +x ~/.solarized/solarize.sh

Add an alias to your shell profile

    alias solarize=~/.solarized/solarize.sh

Select the theme you want

    solarize light
    solarize dark

Credits
-------

[Solarized Theme](http://ethanschoonover.com/solarized) by [Ethan Schoonover](http://ethanschoonover.com/).

[How to setup Solarized for Gnome Terminal](http://www.webupd8.org/2011/04/solarized-must-have-color-paletter-for.html).

[dicolors settings for solarized](https://github.com/seebi/dircolors-solarized) by [Sebastian Tramp](https://github.com/seebi)

[Solarized theme for gnome-terminal](https://github.com/sigurdga/gnome-terminal-colors-solarized) by [Sigurd Gartmann](https://github.com/sigurdga)
