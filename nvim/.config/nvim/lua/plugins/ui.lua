return {
  {
    "folke/tokyonight.nvim", -- Replace with your active theme (e.g., catppuccin/catppuccin-nvim)
    opts = {
      on_highlights = function(hl, c)
        -- Make split lines bold and bright orange/accent color
        hl.WinSeparator = { fg = "#00ffff", bold = true }
      end,
    },
  },
}
