return {
    -- mason: installs language servers
    {
        "mason-org/mason.nvim",
        build = ":MasonUpdate",
        opts = {},
    },

    -- bridges mason with native vim.lsp.config
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = {
            ensure_installed = { "pyright", "lua_ls", "bashls" },
            automatic_installation = true,
        },
    },

    -- nvim-cmp: completion engine
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp     = require("cmp")
            local luasnip = require("luasnip")
            local caps    = require("cmp_nvim_lsp").default_capabilities()

            -- configure servers via native 0.11 API
            vim.lsp.config("pyright",  { capabilities = caps })
            vim.lsp.config("lua_ls",   {
                capabilities = caps,
                settings = { Lua = { diagnostics = { globals = { "vim" } } } },
            })
            vim.lsp.config("bashls",   { capabilities = caps })

            -- enable all configured servers
            vim.lsp.enable({ "pyright", "lua_ls", "bashls" })

            cmp.setup({
                snippet = {
                    expand = function(args) luasnip.lsp_expand(args.body) end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<Tab>"]     = cmp.mapping.select_next_item(),
                    ["<S-Tab>"]   = cmp.mapping.select_prev_item(),
                    ["<CR>"]      = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                }),
            })
        end,
    },
}
