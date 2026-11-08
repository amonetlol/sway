-- lua/mappings.lua
local map = vim.keymap.set

-- CTRL+S = Salvar
-- CTRL+q = wqa
-- CTRL+d = deleta conteudo todo
-- ALT+c = copiar conteudo todo
-- CTRL+n = NvimTreeToggle
-- CTRL+n = NvimTreeFocus
-- SELECT + gf = abrir arquivo
-- ALT+q = fecha buffer
-- Cursor MOUSE + gx = abri link no navegador
-- F1 = cheatsheet
-- F2 = sair sem salvar
-- split = :sp
-- vsplit = :vp
-- Novo Arquivo = :enew
-- :sp | term = split terminal
-- :vp | term = vsplit terminal

-- ### TERMminal ###
-- CTRL + \ = float term
-- Sair = exit

map("n", "<Space>", "<Nop>", { silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Save / quit / copy
local quit_nosave = "<cmd>qa!<CR>"

map("n", "<C-s>", "<cmd>w<CR>", { desc = "Salvar arquivo" })
map("n", "<C-q>", "<cmd>wqa<CR>", { desc = "Salvar e sair de tudo" })
map("n", "<F2>", quit_nosave, { desc = "Sair sem salvar" })
map("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "Salvar arquivo" })
map("i", "<C-q>", "<Esc><cmd>wqa<CR>a", { desc = "Salvar e sair de tudo" })
map("i", "<F2>", "<Esc>" .. quit_nosave, { desc = "Sair sem salvar" })
map("v", "<F2>", "<Esc>" .. quit_nosave, { desc = "Sair sem salvar" })
map("t", "<F2>", [[<C-\><C-n>]] .. quit_nosave, { desc = "Sair sem salvar" })
map("n", "<leader>qq", "<cmd>wqa<CR>", { desc = "Salvar e sair de tudo" })
map("n", "<leader>qQ", "<cmd>qa!<CR>", { desc = "Sair sem salvar" })
map("n", "<A-c>", "<cmd> %y+ <CR>", { desc = "Copiar conteúdo todo" })
map('n', '<C-d>', ':%d<CR>', { noremap = true, silent = true, desc = "Deleta todo conteudo" })

-- Cheatsheet
map("n", "<F1>", "<cmd>edit ~/.config/nvim/lua/mappings.lua<CR>", {
  desc = "Abrir cheatsheet de atalhos",
})

-- Explorer
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Explorer toggle" })
map("n", "<leader>E", "<cmd>NvimTreeFocus<CR>", { desc = "Explorer focus" })

-- Telescope
map("n", "<leader>ff", function()
  require("telescope.builtin").find_files()
end, { desc = "Find files" })

map("n", "<leader>fH", function()
  require("telescope.builtin").find_files {
    cwd = vim.fn.expand "~",
    hidden = true,
  }
end, { desc = "Find files Home" })

map("n", "<leader>fg", function()
  require("telescope.builtin").live_grep()
end, { desc = "Live grep" })

map("n", "<leader>fo", function()
  require("telescope.builtin").oldfiles()
end, { desc = "Recent files" })

map("n", "<leader>fh", function()
  require("telescope.builtin").help_tags()
end, { desc = "Help tags" })

-- Buffers
map("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Próximo buffer" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Buffer anterior" })

map("n", "<A-q>", function()
  local current_buf = vim.api.nvim_get_current_buf()
  local current_ft = vim.bo[current_buf].filetype

  if current_ft == "NvimTree" then
    vim.cmd "wincmd p"
    return
  end

  vim.cmd "BufferLineCycleNext"
  vim.cmd("bdelete " .. current_buf)
end, { desc = "Fechar buffer atual" })

-- Config
map("n", "<leader>ct", "<cmd>Themery<CR>", { desc = "Tema" })
map("n", "<leader>cr", "<cmd>source %<CR>", { desc = "Reload" })
map("n", "<leader>cf", "<cmd>edit ~/.config/nvim/lua/mappings.lua<CR>", {
  desc = "Cheatsheet",
})

-- Format
map("n", "<leader>cm", function()
  require("conform").format()
end, { desc = "Formatar código" })

-- Links e arquivos nativos do Vim
map("n", "gx", "gx", { desc = "Abrir link no navegador" })
map("n", "gf", "gf", { desc = "Abrir arquivo sob cursor" })

-- Copy PATH
vim.keymap.set('n', '<leader>cp', function()
  local full = vim.fn.expand('%:p')
  vim.fn.setreg('+', full)
  print('✅ Caminho completo copiado: ' .. full)
end, { desc = 'Copiar caminho completo do arquivo' })

vim.keymap.set('n', '<leader>cr', function()
  local rel = vim.fn.expand('%')
  vim.fn.setreg('+', rel)
  print('✅ Caminho relativo copiado: ' .. rel)
end, { desc = 'Copiar caminho relativo' })

vim.keymap.set('n', '<leader>cd', function()
  local dir = vim.fn.expand('%:p:h')
  vim.fn.setreg('+', dir)
  print('✅ Diretório copiado: ' .. dir)
end, { desc = 'Copiar diretório do arquivo' })

vim.keymap.set('n', '<leader>cf', function()
  local name = vim.fn.expand('%:t')
  vim.fn.setreg('+', name)
  print('✅ Nome do arquivo copiado: ' .. name)
end, { desc = 'Copiar nome do arquivo' })
