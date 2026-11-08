-- lua/commands.lua

-- Mason: instala todos os servidores e formatadores essenciais
vim.api.nvim_create_user_command("MasonInstallAll", function()
  local ensure_installed = {
    "css-lsp",
    "html-lsp",
    "lua-language-server",
    "typescript-language-server",
    "json-lsp",
    "bash-language-server",
    "stylua",
    "prettier",
  }

  vim.cmd("MasonInstall " .. table.concat(ensure_installed, " "))
end, {})

-- Treesitter automático por filetype
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

-- Instala todos os parsers definidos no treesitter.lua
local create_cmd = vim.api.nvim_create_user_command

create_cmd("TSInstallAll", function()
  local spec = require("lazy.core.config").plugins["nvim-treesitter"]
  local opts = {}

  if type(spec.opts) == "function" then
    opts = spec.opts() or {}
  elseif type(spec.opts) == "table" then
    opts = spec.opts
  end

  require("nvim-treesitter").install(opts.ensure_installed or {})
end, {})
