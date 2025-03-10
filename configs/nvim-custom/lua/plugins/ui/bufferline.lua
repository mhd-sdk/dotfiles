return {
    'akinsho/bufferline.nvim',
    version = "*",
    lazy = false,
    priority = 2,
    keys = {
        { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
        { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    },
    config = function(_, opts)
        local bufferline = require("bufferline")

        bufferline.setup({
            options = {
                always_show_bufferline = true,
                mode = "buffers",
                indicator = {
                    style = 'none',
                },
                separator_style = {
                    '', ''
                },

                offsets = {
                    {
                        text = "file tree",
                        filetype = "neo-tree",
                        highlight = "Directory",
                        text_align = "left",
                    },
                },
            },
        })
    end,
}
