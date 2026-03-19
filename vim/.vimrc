set nocompatible
set nu
set incsearch
set hlsearch
set showmatch
set softtabstop=2
set shiftwidth=2
set expandtab
set modeline
set autoindent
set smartindent
set cindent
set mouse=a

set ignorecase
set smartcase
set magic

set formatoptions+=t
set tw=79

filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin('~/.vim/bundle')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" editing
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-liquid'
Plugin 'Raimondi/delimitMate'
Plugin 'easymotion/vim-easymotion'

" appearance
Plugin 'altercation/vim-colors-solarized'
Plugin 'luochen1990/rainbow'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

" linting
Plugin 'dense-analysis/ale'

" LSP / completion
Plugin 'prabirshri/vim-lsp'
Plugin 'mattn/vim-lsp-settings'
Plugin 'prabirshri/asyncomplete.vim'
Plugin 'prabirshri/asyncomplete-lsp.vim'

" language / format support
Plugin 'elzr/vim-json'
Plugin 'lervag/vimtex'
Plugin 'vim-pandoc/vim-pandoc'
Plugin 'vim-pandoc/vim-pandoc-syntax'

call vundle#end()
filetype plugin indent on

" python indent
autocmd filetype python set expandtab sw=4 softtabstop=4 smarttab

" makes backspace work correctly
set backspace=indent,eol,start

" wildmenu completion
set wildmenu
set wildchar=<Tab>
set wildmode=list:longest
set wildignore+=*.o,*.obj,.git,.svn
set wildignore+=*.png,*.jpg,*.jpeg,*.gif,*.mp3
set wildignore+=*.sw?

" window splits
set wmw=0
set splitbelow
set splitright
nmap <c-h> <c-w>h<c-w><Bar>
nmap <c-l> <c-w>l<c-w><Bar>

" whitespace visibility
set encoding=utf-8
set list
set listchars=nbsp:¬,tab:»·,trail:·

" keymaps
nnoremap ; :
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>
nmap <leader><cr> i<cr><Esc>
imap <c-e> <Esc>A
imap <c-a> <Esc>I

" LSP / asyncomplete tab completion
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? "\<C-y>\<cr>" : "\<cr>"

" spelling
setlocal spell spelllang=en_us

" folds open at start
set foldlevelstart=20

" solarized
let g:solarized_termtrans = 1
set background=dark
colorscheme solarized

" rainbow parens
let g:rainbow_active = 1

" airline
let g:airline_powerline_fonts = 1
set laststatus=2
let g:airline#extensions#ale#enabled = 1
let g:airline_solarized_bg='dark'

" syntax highlighting
if has("syntax")
  syntax on
endif
