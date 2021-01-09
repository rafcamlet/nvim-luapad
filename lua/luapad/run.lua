local function run(opts)
  local context = opts and opts.context or {}
  setmetatable(context, { __index = _G})
  local code = vim.api.nvim_buf_get_lines(0, 0, -1, {})
  local f = loadstring(table.concat(code, '\n'))
  setfenv(f, context)
  if not f then return end
  success, result = pcall(f)
  if not success then print(result) end
end

return {
  run = run,
}
