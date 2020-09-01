local Statusline = require 'luapad/statusline'
local parse_error = require'luapad/tools'.parse_error
local Config = require'luapad/config'
local api = vim.api
local preview_win

local ns = vim.api.nvim_create_namespace('luapad_namespace')
local captured_print_output = {}
local count_limit, error_indicator

local function close_preview()
  vim.schedule(function()
    if preview_win and vim.api.nvim_win_is_valid(preview_win) then
      vim.api.nvim_win_close(preview_win, false)
    end
  end)
end

local function preview()
  if not Config.preview then return end

  local line = vim.api.nvim_win_get_cursor(0)[1]

  if not captured_print_output[line] then return end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'lua')

  local content = vim.split( table.concat(vim.tbl_flatten(captured_print_output[line]), "\n"), "\n")

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

  local lines = tonumber(vim.api.nvim_win_get_height(0)) - 10
  local cols = tonumber(vim.api.nvim_win_get_width(0))
  if vim.api.nvim_call_function('screenrow', {}) >= lines then lines = 0 end

  if preview_win and vim.api.nvim_win_is_valid(preview_win) then
    vim.api.nvim_win_set_buf(preview_win, buf)
    return
  end

  preview_win = vim.api.nvim_open_win(buf, false, {
      relative = 'win',
      col = 0,
      row = lines,
      height = 10,
      width = cols - 1,
      style = 'minimal'
    })
  vim.api.nvim_win_set_option(preview_win, 'signcolumn', 'no')
end


local function single_line(arr)
  local result = {}
  for _, v in ipairs(arr) do
    local str = v:gsub("\n", ''):gsub(' +', ' ')
    table.insert(result, str)
  end
  return table.concat(result, ', ')
end

local function pad_print(...)
  if not ... then return end
  local arg = {...}
  local str = {}

  for _,v in ipairs(arg) do
    table.insert(str, tostring(vim.inspect(v)))
  end

  local line = debug.traceback('', 2):match(':(%d*):')
  if not line then return end
  line = tonumber(line)

  if not captured_print_output[line] then
    captured_print_output[line] = {}
  end

  table.insert(captured_print_output[line], str)
end

local function tcall(fun)
  if count_limit < 1000 then count_limit = 1000 end
  success, result = pcall(function()
    debug.sethook(function() error('LuapadTimeoutError') end, "", count_limit)
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

  count_limit = Config.count_limit
  error_indicator = Config.error_indicator

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

  for line, arr in pairs(captured_print_output) do
    local res = {}

    for _, v in ipairs(arr) do
      table.insert(res, single_line(v))
    end

    vim.api.nvim_buf_set_virtual_text(
      0,
      ns,
      line - 1,
      {{'  ' .. table.concat(res, ' | '), 'Comment'}},
      {}
      )
  end
end

local function init_luapad()
  api.nvim_command('botright vnew')
  api.nvim_buf_set_name(0, 'Luapad #' .. api.nvim_get_current_buf())
  api.nvim_buf_set_option(0, 'swapfile', false)
  api.nvim_buf_set_option(0, 'filetype', 'lua.luapad')
  api.nvim_buf_set_option(0, 'bufhidden', 'wipe')
  api.nvim_command('au CursorHold <buffer> lua require("luapad").preview()')
  api.nvim_command('au CursorMoved <buffer> lua require("luapad").close_preview()')
  api.nvim_command('au CursorMovedI <buffer> lua require("luapad").close_preview()')
  api.nvim_command('au QuitPre <buffer> set nomodified')

  vim.api.nvim_buf_attach(0, false, {
      on_lines = vim.schedule_wrap(luapad),
      on_changedtick = vim.schedule_wrap(luapad),
      on_detach = close_preview
    })
end

return {
  init_luapad = init_luapad,
  luapad = luapad,
  preview = preview,
  close_preview = close_preview
}
