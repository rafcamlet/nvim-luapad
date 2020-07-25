local function run_lua()
  local context = {}
  setmetatable(context, { __index = _G})
  local code = vim.api.nvim_buf_get_lines(0, 0, -1, {})
  local f = loadstring(table.concat(code, '\n'))
  if not f then return end
  success, result = pcall(f)
  if not success then print(result) end
end

return run_lua
