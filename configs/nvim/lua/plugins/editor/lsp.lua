return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            -- Useful status updates for LSP.
            { 'j-hui/fidget.nvim', opts = {} },
        },
        config = function()
            require("lspconfig").lua_ls.setup {}
            require("lspconfig").gopls.setup {}

            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if not client then return end

                    if client.supports_method('textDocument/formatting') then
                        vim.api.nvim_create_autocmd('BufWritePre', {
                            buffer = args.buf,
                            callback = function()
                                vim.lsp.buf.format({ bufn = args.buf, id = client.id })
                            end,
                        })
                    end
                end,
            })
        end,
    }
}
