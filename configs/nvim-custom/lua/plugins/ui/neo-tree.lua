-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
    },
    enabled = false,
    cmd = 'Neotree',
    keys = {
        { '\\', ':Neotree toggle<CR>', desc = 'NeoTree toggle', silent = true },
    },
    opts = {
        filesystem = {
            window = {
                mappings = {
                    ['\\'] = 'close_window',
                },
            },
        },
    },
    config = function()
        require("neo-tree").setup({
            enable_git_status = false
        })
    end
}
