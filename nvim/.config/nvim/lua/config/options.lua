-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.clipboard = "unnamedplus" -- Replace thin split lines with thick box-drawing characters
vim.opt.fillchars:append({
  vert = "┃",
  vertleft = "┫",
  vertright = "┣",
  verthoriz = "╋",
  horiz = "━",
  horizup = "┻",
  horizdown = "┳",
})
