local print_error = require'luapad.tools'.print_error
local parse_error = require'luapad.tools'.parse_error

local function print_run_error(err)
  local line_nr, msg = parse_error(err)
  print_error(('error on line %s: %s'):format(line_nr, msg))
end

local function run(opts)
  local context = opts and opts.context or {}
  setmetatable(context, { __index = _G})

  local code = vim.api.nvim_buf_get_lines(0, 0, -1, {})
  local f, error_str = loadstring(table.concat(code, '\n'))
  if not f then return print_run_error(error_str) end

  setfenv(f, context)
  local success, result = pcall(f)
  if not success then return print_run_error(result) end
end

return {
  run = run
}
