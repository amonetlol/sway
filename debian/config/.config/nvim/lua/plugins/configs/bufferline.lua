return {
  options = {
    mode = "buffers",
    numbers = "none",
    close_command = "bdelete! %d",
    right_mouse_command = "bdelete! %d",
    left_mouse_command = "buffer %d",
    middle_mouse_command = "bdelete! %d",

    indicator = {
      style = "icon",
    },

    buffer_close_icon = "󰅖",
    modified_icon = "●",
    close_icon = "",
    left_trunc_marker = "",
    right_trunc_marker = "",

    max_name_length = 24,
    max_prefix_length = 15,
    truncate_names = true,
    tab_size = 18,

    diagnostics = "nvim_lsp",

    offsets = {
      {
        filetype = "NvimTree",
        text = "Explorer",
        text_align = "center",
        separator = true,
      },
    },

    show_buffer_icons = true,
    show_buffer_close_icons = true,
    show_close_icon = false,
    show_tab_indicators = true,
    persist_buffer_sort = true,
    separator_style = "thin",

    always_show_bufferline = true,
  },
}
