local o = vim.opt

o.number         = true
o.expandtab      = true
o.shiftwidth     = 2
o.softtabstop    = 2
o.autoindent     = true
o.smartindent    = true
o.ignorecase     = true
o.smartcase      = true
o.incsearch      = true
o.hlsearch       = true
o.showmatch      = true
o.mouse          = "a"
o.textwidth      = 79
o.formatoptions:append("t")
o.foldlevelstart = 20
o.splitbelow     = true
o.splitright     = true
o.list           = true
o.listchars      = { nbsp = "¬", tab = "»·", trail = "·" }
o.wildmode       = "list:longest"
o.wildignore:append({ "*.o", "*.obj", ".git", ".svn", "*.png", "*.jpg", "*.sw?" })
o.backspace      = "indent,eol,start"
o.laststatus     = 2
o.spell          = true
o.spelllang      = { "en_us" }
o.termguicolors  = true

-- use system clipboard
o.clipboard      = "unnamedplus"

vim.g.mapleader  = " "
