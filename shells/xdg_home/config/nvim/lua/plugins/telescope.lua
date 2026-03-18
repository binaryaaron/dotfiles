return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>",  desc = "Find files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>",   desc = "Live grep" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>",     desc = "Buffers" },
            { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Symbols" },
            { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
            { "<leader>fr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
        },
        opts = {},
    },
}
