return {
    { "tpope/vim-fugitive" },
    { "tpope/vim-repeat" },
    { "tpope/vim-liquid" },

    -- surround: sa, sd, sr operators
    {
        "kylechui/nvim-surround",
        event = "VeryLazy",
        opts = {},
    },

    -- commenting: gc operator
    {
        "numToStr/Comment.nvim",
        event = "VeryLazy",
        opts = {},
    },

    -- auto-close pairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {},
    },

    -- motion: s<char><char> to jump
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        keys = {
            { "s",     function() require("flash").jump() end,              desc = "Flash jump" },
            { "S",     function() require("flash").treesitter() end,        desc = "Flash treesitter" },
            { "r",     function() require("flash").remote() end,            mode = "o",               desc = "Remote flash" },
        },
    },

    -- treesitter v1: highlight and indent are on by default; just ensure parsers
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        lazy = false,
        config = function()
            require("nvim-treesitter").setup()
            vim.schedule(function()
                require("nvim-treesitter.install").install(
                    "bash", "python", "lua", "json", "yaml", "markdown", "latex"
                )
            end)
        end,
    },
}
