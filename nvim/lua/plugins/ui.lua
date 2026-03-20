return {
    -- statusline
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            theme = "solarized_dark",
            extensions = { "fugitive" },
        },
    },

    -- colorscheme
    {
        "maxmx03/solarized.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("solarized").setup({
                styles = { transparency = true },
            })
            vim.cmd.colorscheme("solarized")
        end,
    },

    -- rainbow delimiters
    { "HiPhish/rainbow-delimiters.nvim" },

    -- which-key: shows available keymaps as you type
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {},
    },
}
