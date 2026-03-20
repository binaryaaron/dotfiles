local map = vim.keymap.set

-- clear search highlight
map("n", "<Space>", "<cmd>nohlsearch<cr>", { silent = true })

-- ; as : (save a shift)
map("n", ";", ":")

-- window navigation
map("n", "<C-h>", "<C-w>h<C-w>|")
map("n", "<C-l>", "<C-w>l<C-w>|")

-- break line at cursor without entering insert mode
map("n", "<leader><cr>", "i<cr><Esc>")

-- jump to end/start of line from insert mode
map("i", "<C-e>", "<Esc>A")
map("i", "<C-a>", "<Esc>I")

-- LSP (set on LspAttach so only active when a server is running)
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }
        map("n", "gd",         vim.lsp.buf.definition,      opts)
        map("n", "gD",         vim.lsp.buf.declaration,     opts)
        map("n", "gr",         vim.lsp.buf.references,      opts)
        map("n", "gi",         vim.lsp.buf.implementation,  opts)
        map("n", "K",          vim.lsp.buf.hover,           opts)
        map("n", "<leader>rn", vim.lsp.buf.rename,          opts)
        map("n", "<leader>ca", vim.lsp.buf.code_action,     opts)
        map("n", "<leader>f",  vim.lsp.buf.format,          opts)
        map("n", "[d",         vim.diagnostic.goto_prev,    opts)
        map("n", "]d",         vim.diagnostic.goto_next,    opts)
    end,
})
