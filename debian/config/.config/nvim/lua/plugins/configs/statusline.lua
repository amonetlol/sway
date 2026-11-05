-- lua/plugins/configs/statusline.lua

local statusline = require("mini.statusline")

statusline.setup({
  use_icons = true,
  content = {
    active = function()
      local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
      local filename = statusline.section_filename({ trunc_width = 140 })
      local location = statusline.section_location({ trunc_width = 75 })
      local search = statusline.section_searchcount({ trunc_width = 75 })

      return statusline.combine_groups({
        { hl = mode_hl, strings = { mode } },
        { hl = "MiniStatuslineDevinfo", strings = { filename } },
        "%=",
        { hl = "MiniStatuslineFileinfo", strings = { search, location } },
      })
    end,
  },
})
