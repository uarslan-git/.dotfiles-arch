return {
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        dependencies = {
            'neovim/nvim-lspconfig',
            'hrsh7th/nvim-cmp',
            'hrsh7th/cmp-nvim-lsp',
        },
        config = function()
            local lsp_zero = require('lsp-zero')

            local lsp_attach = function(client, bufnr)
                local opts = {buffer = bufnr}

                vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
                vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
                vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
                vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.document_symbol()<cr>', opts)
                vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
                vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
                vim.keymap.set('n', 'gE', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
                vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
                vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
                vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
                vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
                vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
            end

            vim.lsp.set_log_level("debug")

            lsp_zero.extend_lspconfig({
                sign_text = true,
                lsp_attach = lsp_attach,
                capabilities = require('cmp_nvim_lsp').default_capabilities(),
            })

            -- LSP Server configurations
            require('lspconfig').ccls.setup({})
            require('lspconfig').clangd.setup({})
            require('lspconfig').csharp_ls.setup({
                --        cmd = { vim.fn.expand("~/.dotnet/tools/csharp-ls") },
                --        filetypes = { "cs", "csharp" },
                --        root_dir = require('lspconfig.util').root_pattern("*.sln", "*.csproj", ".git"),
            })
            require('lspconfig').cssls.setup({})
            require('lspconfig').denols.setup({})
            require('lspconfig').dockerls.setup({})
            require('lspconfig').graphql.setup({})
            require('lspconfig').hls.setup({})
            require('lspconfig').html.setup({})
            require('lspconfig').java_language_server.setup({})
            require('lspconfig').jsonls.setup({})
            require('lspconfig').kotlin_language_server.setup({})
            require('lspconfig').lua_ls.setup({})
            require('lspconfig').marksman.setup({})
            require('lspconfig').pyright.setup({})
            require('lspconfig').sqlls.setup({})
            require('lspconfig').texlab.setup({})
            require('lspconfig').ts_ls.setup({})
            require('lspconfig').volar.setup({})
            require('lspconfig').bashls.setup({})

            -- Autocompletion setup
            local cmp = require('cmp')
            cmp.setup({
                sources = {
                    {name = 'nvim_lsp'},
                    {name = 'vim_snippet', priority = 1000 },
                    {name = 'buffer'},
                },
                snippet = {
                    expand = function(args)
                        vim.snippet.expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<CR>'] = cmp.mapping.confirm({select = true}),
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-d>'] = cmp.mapping.scroll_docs(4),
                }),
            })
        end
    }
}
