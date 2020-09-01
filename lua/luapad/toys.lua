local function vprint(str, color)

  local line = debug.traceback('', 2):match(':(%d*):')
  if not line then return end
  line = tonumber(line) - 1

  vim.api.nvim_buf_set_virtual_text(
    0, 0, line, {{tostring(str), color or 'Comment'}}, {}
  )
end

return {
  vprint = vprint
}
