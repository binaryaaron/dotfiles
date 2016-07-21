#!/bin/bash
# installs vim extensions for jupyter; requires jupyter
if [ -d $(jupyter --data-dir) ]; then
    mkdir -p $(jupyter --data-dir)/nbextensions
    cd $(jupyter --data-dir)/nbextensions
    git clone https://github.com/lambdalisue/jupyter-vim-binding vim_binding
    jupyter nbextension enable vim_binding/vim_binding
    cp jupyter_notebook_custom.css ~/.jupyter/custom/custom.css
fi
