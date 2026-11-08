-- lua/plugins/configs/toggleterm.lua

local toggleterm = require "toggleterm"
local Terminal = require("toggleterm.terminal").Terminal

toggleterm.setup {
  size = 12,
  direction = "float",
  open_mapping = [[<C-\>]],

  hide_numbers = true,
  shade_terminals = true,
  persist_size = true,
  persist_mode = true,
  close_on_exit = true,

  insert_mappings = true,
  terminal_mappings = true,

  float_opts = {
    border = "curved",
    width = function()
      return math.floor(vim.o.columns * 0.85)
    end,
    height = function()
      return math.floor(vim.o.lines * 0.75)
    end,
  },
}

local float_term = Terminal:new {
  direction = "float",
  hidden = true,
}

local horizontal_term = Terminal:new {
  direction = "horizontal",
  size = 12,
  hidden = true,
}

local lazygit = Terminal:new {
  cmd = "lazygit",
  direction = "float",
  hidden = true,
}

-- Terminal flutuante
vim.keymap.set({ "n", "t" }, "<leader>tf", function()
  float_term:toggle()
end, { desc = "Terminal flutuante" })

-- Terminal horizontal
vim.keymap.set({ "n", "t" }, "<leader>th", function()
  horizontal_term:toggle()
end, { desc = "Terminal horizontal" })

-- LazyGit
-- vim.keymap.set("n", "<leader>gg", function()
--   lazygit:toggle()
-- end, { desc = "LazyGit" })

-- Atalho rápido alternativo
vim.keymap.set({ "n", "t" }, "<C-\\>", "<cmd>ToggleTerm<CR>", {
  desc = "Toggle terminal",
})

-- Keymaps internos do terminal
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*",
  callback = function(event)
    local opts = { buffer = event.buf, silent = true }

    -- Esc fecha/esconde o terminal
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n><cmd>ToggleTerm<CR>]], opts)

    -- jk apenas sai do modo terminal para modo normal
    vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)

    -- Navegação entre janelas
    vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], opts)
    vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], opts)
    vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], opts)
    vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], opts)
  end,
})
