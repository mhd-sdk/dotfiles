local conform = require "conform"

conform.formatters.qmlformat = {
  command = "qmlformat",
  args = { "--inplace", "$FILENAME" },
  stdin = false,
}

local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    qml = { "qmlformat" },
  },

  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
    lsp_format = "fallback",
  },
}

return options
