local Statusline = require 'lib/statusline'
local get_var =  require'lib/tools'.get_var
local get_bool_var =  require'lib/tools'.get_bool_var
local parse_error = require'lib/tools'.parse_error
local api = vim.api

local ns = vim.api.nvim_create_namespace('luapad_namespace')
local captured_print_output = {}
local count_limit, error_indicator

local function pad_print(...)
  if ... == nil then return end
  local arg = {...}
  local str = {}

  for _,v in ipairs(arg) do
    table.insert(str, tostring(vim.inspect(v):gsub("\n", '')))
  end

  table.insert(captured_print_output, {
      arg = '  ' .. table.concat(str, ', '),
      line = debug.traceback('', 2):match(':(%d*):')
    })
end

local function tcall(fun)
  local tick_count = 0
  success, result = pcall( function()
    local tick = function()
      tick_count = tick_count + 1

      if tick_count > count_limit then
        tick_count = 0
        error('LuapadTimeoutError')
      end
    end
    debug.sethook(tick, "c", 1)
    fun()
  end)

  if not success then
    if result:find('LuapadTimeoutError') then
      Statusline:set_status('timeout')
    else
      Statusline:set_status('error')
      local line, error_msg = parse_error(result)
      Statusline:set_msg(('%s: %s'):format((line or ''), (error_msg or '')))

      if error_indicator and line then
        vim.api.nvim_buf_set_virtual_text(
          0, ns, tonumber(line) - 1, {{tostring('<-- ' .. error_msg), 'ErrorMsg'}}, {}
          )
      end
    end
  end

  debug.sethook()
end

local function luapad()
  local context = { p = pad_print, print = pad_print }
  setmetatable(context, { __index = _G})

  vim.api.nvim_buf_set_option(0, 'modified', false)
  count_limit = get_var('luapad__count_limit', 1.5 * 1e5)
  error_indicator = get_bool_var('luapad__error_indicator', true)
  Statusline:clear()

  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

  captured_print_output = {}
  local code = vim.api.nvim_buf_get_lines(0, 0, -1, {})

  local f, result = loadstring(table.concat(code, '\n'))
  if not f then
    local _, msg = parse_error(result)
    Statusline:set_status('syntax')
    Statusline:set_msg(msg)
    return
  end

  setfenv(f, context)
  tcall(f)

  for _,v in ipairs(captured_print_output) do
    vim.api.nvim_buf_set_virtual_text(
      0,
      ns,
      tonumber(v['line']) - 1,
      {{tostring(v['arg']), 'Comment'}},
      {}
      )
  end
end

local function init_luapad()
  api.nvim_command('botright vnew')
  api.nvim_buf_set_name(0, '__Luapad__ ' .. api.nvim_get_current_buf())
  api.nvim_buf_set_option(0, 'swapfile', false)
  api.nvim_buf_set_option(0, 'filetype', 'lua.luapad')
  api.nvim_buf_set_option(0, 'bufhidden', 'wipe')

  vim.api.nvim_buf_attach(0, false, { on_lines = luapad })
end

return {
  init_luapad = init_luapad,
  luapad = luapad
}
