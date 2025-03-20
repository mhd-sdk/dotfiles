local cmp = require "cmp"

-- Disable Tab for nvim-cmp
cmp.setup {
  mapping = {
    -- Use another key for completion (e.g., Ctrl + j for next item)
    ["<C-J>"] = cmp.mapping.select_next_item(),
    ["<C-K>"] = cmp.mapping.select_prev_item(),
    -- Optional: Mapping to confirm a completion
    ["<CR>"] = cmp.mapping.confirm { select = true },
  },
}
-- cmp.event:on("menu_opened", function()
--   vim.b.copilot_suggestion_hidden = true
-- end)
--
-- cmp.event:on("menu_closed", function()
--   vim.b.copilot_suggestion_hidden = false
-- end)
