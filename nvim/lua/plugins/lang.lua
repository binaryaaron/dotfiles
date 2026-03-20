return {
    -- LaTeX
    {
        "lervag/vimtex",
        ft = { "tex" },
        init = function()
            vim.g.vimtex_view_method = "zathura"
        end,
    },

    -- Markdown / pandoc
    { "vim-pandoc/vim-pandoc" },
    { "vim-pandoc/vim-pandoc-syntax" },

    -- JSON
    { "elzr/vim-json", ft = { "json" } },
}
