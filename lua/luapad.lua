local api = vim.api
local ns = vim.api.nvim_create_namespace('luapad_namespace')
local captured_print_output = {}

local function pad_print(...)
  if not ... then return end
  local arg = {...}
  local str = {}

  for i,v in ipairs(arg) do
    table.insert(str, tostring(vim.inspect(v):gsub("\n", '')))
  end

  table.insert(captured_print_output, {
      arg = '  ' .. table.concat(str, ', '),
      line = debug.traceback('', 2):match(':(%d*):')
    })
end

local context = {
  p = pad_print,
  print = pad_print
}
setmetatable(context, { __index = _G })

local function timeout_call(fun)
  local tick_count = 0
  success, result = pcall( function()
    local tick = function()
      tick_count = tick_count + 1

      if tick_count > 1.5 * 1e5 then
        tick_count = 0
        error('LuapadTimeoutError')
      end
    end
    debug.sethook(tick, "c", 1)
    fun()
  end)
  debug.sethook()
end

local function luapad()
  captured_print_output = {}
  local code = vim.api.nvim_buf_get_lines(0, 0, -1, {})

  local f = loadstring(table.concat(code, '\n'))
  if not f then return end

  setfenv(f, context)
  timeout_call(f)

  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  for i,v in ipairs(captured_print_output) do
    vim.api.nvim_buf_set_virtual_text(
      0,
      ns,
      tonumber(v['line']) - 1,
      {{tostring(v['arg']), 'Comment'}},
      {}
      )
  end
end

function init_luapad(new_window)
  if new_window then
    api.nvim_command('rightbelow vnew')
    api.nvim_buf_set_option(0, 'buftype', 'nofile')
    api.nvim_buf_set_option(0, 'swapfile', false)
  end
  api.nvim_buf_set_option(0, 'filetype', 'lua')
  api.nvim_buf_set_option(0, 'bufhidden', 'wipe')
  -- api.nvim_buf_set_name(0, '  Luapad')

  vim.api.nvim_command [[autocmd CursorHold   <buffer> lua require'luapad'.luapad()]]
  vim.api.nvim_command [[autocmd TextChanged  <buffer> lua require'luapad'.luapad()]]
  vim.api.nvim_command [[autocmd TextChangedI <buffer> lua require'luapad'.luapad()]]
end

return {
  init_luapad = init_luapad,
  luapad = luapad
}
