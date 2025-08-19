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

                -- Hover info
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

                -- Go-to navigation
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)

                -- Symbols
                vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
                vim.keymap.set('n', 'gS', vim.lsp.buf.document_symbol, opts)  -- changed from gd → gS
                vim.keymap.set('n', 'gW', vim.lsp.buf.workspace_symbol, opts) -- extra

                -- Diagnostics
                vim.keymap.set('n', 'gE', vim.diagnostic.open_float, opts)   -- fixed from gE → ge
                vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
                vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

                -- References
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

                -- Refactor / actions
                vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
                vim.keymap.set({'n','x'}, '<F3>', function() vim.lsp.buf.format({async = true}) end, opts)
                vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, opts)
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
