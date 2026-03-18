return {
    -- avante: Cursor-like AI sidebar with inline diffs
    -- requires ANTHROPIC_API_KEY in environment (set via .bashenv / .local.envrc)
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        build = "make",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
            "hrsh7th/nvim-cmp",
        },
        opts = {
            provider = "claude",
            claude = {
                model = "claude-sonnet-4-5",
            },
        },
    },
}
