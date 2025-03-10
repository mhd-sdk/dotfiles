return {
    'nvim-lualine/lualine.nvim',
    options = {
        globalstatus = true,
    },
    config = function()
        require("lualine").setup({
            options = {
                theme = "auto",      -- Auto-detect theme
                globalstatus = true, -- Single statusline for all windows
                component_separators = { left = '', right = '' },
                section_separators = { left = '', right = '' },
            }
        })
    end,
}
