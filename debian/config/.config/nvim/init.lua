require "options"
require "mappings"
require "commands"

-- bootstrap plugins & lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim" -- path where its going to be installed

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end

vim.opt.rtp:prepend(lazypath)

local plugins = require "plugins"

require("lazy").setup(plugins, require "lazy_config")

-- THEME CONFIG ANTES DO THEMERY
--vim.cmd "colorscheme nightfox"
--vim.cmd "colorscheme kanagawa"
--vim.cmd "colorscheme vague"
-- vim.cmd "colorscheme catppuccin-frappe"
-- vim.cmd "colorscheme moonfly"
-- vim.cmd "colorscheme nordic"
-- vim.cmd "colorscheme everforest"
