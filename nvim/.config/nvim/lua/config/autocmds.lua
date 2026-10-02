-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
  pattern = "*.java",
  callback = function(args)
    -- only act on empty buffers
    local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
    if #lines > 1 or (lines[1] and lines[1] ~= "") then
      return
    end

    local path = vim.api.nvim_buf_get_name(args.buf)
    local name = vim.fn.fnamemodify(path, ":t:r")

    local pkg = path:match("src/main/java/(.+)/[^/]+%.java$") or path:match("src/test/java/(.+)/[^/]+%.java$")

    local out = {}
    if pkg then
      table.insert(out, "package " .. (pkg:gsub("/", ".")) .. ";")
      table.insert(out, "")
    end

    local kind = "class"
    if
      name:match("Service$")
      or name:match("Controller$")
      or name:match("Adapter$")
      or name:match("Entity$")
      or name:match("Mapper$")
      or name:match("Exception$")
    then
      kind = "class"
    elseif
      name:match("^Register")
      or name:match("^Change")
      or name:match("^Delete")
      or name:match("Queries$")
      or name:match("Repository$")
    then
      kind = "interface"
    elseif name:match("Request$") or name:match("Response$") then
      kind = "record"
    end

    if kind == "record" then
      table.insert(out, "public record " .. name .. "() {")
    else
      table.insert(out, "public " .. kind .. " " .. name .. " {")
    end
    table.insert(out, "")
    table.insert(out, "}")

    vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, out)
  end,
})
