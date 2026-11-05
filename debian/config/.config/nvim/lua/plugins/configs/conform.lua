-- lua/plugins/configs/conform.lua

return {
  formatters_by_ft = {
    lua = { "stylua" },

    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },

    json = { "prettier" },
    jsonc = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    scss = { "prettier" },
    markdown = { "prettier" },
    yaml = { "prettier" },
  },

  format_on_save = function(bufnr)
    local disabled_filetypes = {
      c = true,
      cpp = true,
    }

    if disabled_filetypes[vim.bo[bufnr].filetype] then
      return nil
    end

    return {
      timeout_ms = 500,
      lsp_format = "fallback",
    }
  end,
}
