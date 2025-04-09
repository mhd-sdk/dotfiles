require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })

map("i", "<C-s>", "<Esc>:w<CR>", { desc = "Save file and exit insert mode" })
