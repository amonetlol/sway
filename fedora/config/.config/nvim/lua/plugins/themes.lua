return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },

  {
    "rebelot/kanagawa.nvim",
    priority = 900,
    lazy = false,
  },

  {
    "vague-theme/vague.nvim",
    priority = 900,
    lazy = false,
  },

  {
    "bluz71/vim-moonfly-colors",
    priority = 900,
    lazy = false,
  },

  {
    "AlexvZyl/nordic.nvim",
    priority = 900,
    lazy = false,
  },

  {
    "neanias/everforest-nvim",
    priority = 900,
    lazy = false,
  },

  {
    "ellisonleao/gruvbox.nvim",
    priority = 900,
    lazy = false,
  },

  {
    "EdenEast/nightfox.nvim",
    priority = 900,
    lazy = false,
  },

  {
    "shaunsingh/nord.nvim",
    priority = 900,
    lazy = false,
  },

  {
    "Mofiqul/dracula.nvim",
    priority = 900,
    lazy = false,
  },

  {
    "craftzdog/solarized-osaka.nvim",
    priority = 900,
    lazy = false,
  },

  {
    "sainnhe/sonokai",
    priority = 900,
    lazy = false,
  },

  {
    "navarasu/onedark.nvim",
    priority = 900,
    lazy = false,
  },

  {
    "savq/melange-nvim",
    priority = 900,
    lazy = false,
  },

  {
    "ribru17/bamboo.nvim",
    priority = 900,
    lazy = false,
  },

  {
    "sainnhe/edge",
    priority = 900,
    lazy = false,
  },

  {
    "folke/tokyonight.nvim",
    priority = 900,
    lazy = false,
  },

  {
    "vossenwout/guts.nvim",
    priority = 900,
    lazy = false,
  },

  {
    "jpwol/thorn.nvim",
    lazy = false,
    priority = 900,
  },

  {
    "metalelf0/kintsugi-nvim",
    lazy = false,
    priority = 900,
    config = function()
    require("kintsugi").setup({
      variant = "dark"
    })
    -- vim.cmd.colorscheme("kintsugi")   ← não coloque aqui
  end,
  },

  {
    "ember-theme/nvim",
    name = "ember",
    lazy = false,
    priority = 900,
  },

  {
   "zitrocode/carvion.nvim",
    lazy = false,
    priority = 900,
  },

  {
   'ThorstenRhau/token',
   lazy = false,
   priority = 900,
  },

  {
    "danfry1/lume",
    lazy = false,
    priority = 900,
   },

   {
    "mitander/flume.nvim",
    version = "v0.2.0",
    lazy = false,
    priority = 900,
   },

   {
    "g-kirti/hardhat.nvim",
    lazy = false,
    priority = 900,
   },

  {
    "oxidescheme/nvim",
    name = "oxide",
    lazy = false,
    priority = 900,
  },

  {
    "zaldih/themery.nvim",
    lazy = false,
    config = function()
      require("themery").setup({
        themes = {
          "hardhat",
          "flume-dusk",
          "flume-opal",
          "flume-mira",
          "flume-mesa",
          "catppuccin-frappe",
          "catppuccin-mocha",
          "kanagawa",
          "vague",
          "moonfly",
          "nordic",
          "everforest",
          "gruvbox",
          "nightfox",
          "nord",
          "dracula",            
          "solarized-osaka",
          "sonokai",
          "melange",
          "bamboo",
          "edge",
          "onedark",
          "tokyonight",
          "guts",
          "thorn",
          "kintsugi-dark",
          "ember",
          "carvion",
          "lume",
          "oxide",
        },
        livePreview = true,
      })
    end,
  },
}
