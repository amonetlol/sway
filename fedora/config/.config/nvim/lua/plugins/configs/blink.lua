return {
  keymap = {
    preset = "default",

    ["<CR>"] = { "select_and_accept", "fallback" },

    ["<Tab>"] = { "select_next", "fallback" },
    ["<S-Tab>"] = { "select_prev", "fallback" },

    ["<C-j>"] = { "select_next", "fallback" },
    ["<C-k>"] = { "select_prev", "fallback" },
  },

  appearance = {
    nerd_font_variant = "mono",
  },

  sources = {
    default = { "lsp", "path", "snippets", "buffer" },

    providers = {
      path = {
        opts = {
          show_hidden_files_by_default = true,
        },
        -- trigger_characters = { "/", ".", "~" },
      },
    },
  },

  completion = {
    list = {
      selection = {
        preselect = true,
        auto_insert = false,
      },
    },

    menu = {
      border = "single",
    },

    documentation = {
      auto_show = true,
      auto_show_delay_ms = 300,
      window = {
        border = "single",
      },
    },
  },

  signature = {
    enabled = true,
    window = {
      border = "single",
    },
  },
}
