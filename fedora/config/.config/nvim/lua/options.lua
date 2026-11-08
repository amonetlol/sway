local o = vim.o

vim.g.mapleader = " "

o.laststatus = 3 -- global statusline
o.showmode = false

o.clipboard = "unnamedplus"

-- Indenting
o.expandtab = true
o.shiftwidth = 2
o.smartindent = true
o.tabstop = 2
o.softtabstop = 2

vim.opt.fillchars = { eob = " " }
o.ignorecase = true
o.smartcase = true
o.mouse = "a"

o.number = true

o.signcolumn = "yes"
o.splitbelow = true
o.splitright = true
o.termguicolors = true
o.timeoutlen = 400

-- Neovim 0.12 + foot: kitty keyboard protocol can make F-keys unreliable
if vim.fn.has("nvim-0.12") == 1 and vim.env.TERM and vim.env.TERM:match("^foot") then
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      io.stdout:write("\027[>1u")
    end,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      io.stdout:write("\027[<1u")
    end,
  })
end
o.undofile = true
o.cursorline = true

-- add binaries installed by mason.nvim to path
local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
vim.env.PATH = vim.env.PATH .. (is_windows and ";" or ":") .. vim.fn.stdpath "data" .. "/mason/bin"

vim.api.nvim_set_hl(0, "IndentLine", { link = "Comment" })
