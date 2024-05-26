local Config = require 'luapad.config'.config
local set_config = require 'luapad.config'.set_config
local State = require 'luapad.state'
local utils = require 'luapad.utils'

local tools = require'luapad.tools'
local Benchmark = require'luapad.benchmark'
local parse_error = tools.parse_error
local table_find = tools.table_find


local ns = vim.api.nvim_create_namespace('luapad_namespace')

Evaluator = {}
Evaluator.__index = Evaluator

local function single_line(arr)
  local result = {}
  for _, v in ipairs(arr) do
    local str = v:gsub("\n", ''):gsub(' +', ' ')
    table.insert(result, str)
  end
  return table.concat(result, ', ')
end

function Evaluator:set_virtual_text(line, str, color)
  vim.api.nvim_buf_set_virtual_text(
    self.buf,
    ns,
    line,
    {{tostring(str), color}},
    {}
  )
end

function Evaluator:update_view()
  if not self.buf then return end
  if not vim.api.nvim_buf_is_valid(self.buf) then return end

  for line, arr in pairs(self.output) do
    local res = {}
    for _, v in ipairs(arr) do table.insert(res, single_line(v)) end
    self:set_virtual_text(line - 1, '  '..table.concat(res, ' | '), Config.print_highlight)
  end
end

function Evaluator:tcall(fun)
  local count_limit = Config.count_limit < 1000 and 1000 or Config.count_limit

  success, result = pcall(function()
    debug.sethook(function() error('LuapadTimeoutError') end, "", count_limit)
    fun()
  end)

  if not success then
    if result:find('LuapadTimeoutError') then
      self.statusline.status = 'timeout'
    else
      self.statusline.status = 'error'
      local line, error_msg = parse_error(result)
      self.statusline.msg = ('%s: %s'):format((line or ''), (error_msg or ''))

      if Config.error_indicator and line then
        self:set_virtual_text(tonumber(line) - 1, '<-- '..error_msg, Config.error_highlight)
      end
    end
  end

  debug.sethook()
end

function Evaluator:print(...)
  local size = select('#', ...)
  if size == 0 then return end

  local args = {...}
  local str = {}

  for i=1, size do
    table.insert(str, tostring(vim.inspect(args[i])))
  end

  local line = debug.traceback('', 3):match('^.-]:(%d-):')
  if not line then return end
  line = tonumber(line)

  if not self.output[line] then self.output[line] = {} end
  table.insert(self.output[line], str)
end

function Evaluator:eval()
  local context = self.context or vim.deepcopy(Config.context) or {}
  local luapad_print = function(...) self:print(...) end

  context.luapad = self
  context.p = luapad_print
  context.print = luapad_print
  context.luapad = self.helper

  setmetatable(context, { __index = _G})

  self.statusline = { status = 'ok' }

  vim.api.nvim_buf_clear_namespace(self.buf, ns, 0, -1)

  self.output = {}

  local code = vim.api.nvim_buf_get_lines(self.buf, 0, -1, {})
  local benchmark_line, benchmark_line_num = table_find(code, function (line)
    return line:match("-- #luapad:benchmark") ~= nil
  end)
  local benchmark_iterations = tonumber(benchmark_line and benchmark_line:match("-- #luapad:benchmark (%d+)") or 10)

  local f, result = loadstring(table.concat(code, '\n'))

  if not f then
    local _, msg = parse_error(result)
    self.statusline.status = 'syntax'
    self.statusline.msg = msg
    return
  end

  setfenv(f, context)
  if benchmark_line ~= nil then
    print(("%s %s"):format(type(benchmark_line_num), benchmark_line_num))
    local handle_result = function(result_line)
      self:set_virtual_text(benchmark_line_num - 1, result_line, Config.benchmark_highlight)
    end
    Benchmark:start_benchmark(f, benchmark_iterations, handle_result)
  end

  self:tcall(f)
  self:update_view()
end

function Evaluator:close_preview()
  vim.schedule(function()
    if self.preview_win and vim.api.nvim_win_is_valid(self.preview_win) then
      vim.api.nvim_win_close(self.preview_win, false)
    end
  end)
end

function Evaluator:preview()
  local line = vim.api.nvim_win_get_cursor(0)[1]

  if not self.output[line] then return end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'lua')

  local content = vim.split(table.concat(utils.tbl_flatten(self.output[line]), "\n"), "\n")

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

  local lines = tonumber(vim.api.nvim_win_get_height(0)) - 10
  local cols = tonumber(vim.api.nvim_win_get_width(0))
  if vim.fn.screenrow() >= lines then lines = 0 end

  local opts = {
    relative = 'win',
    col = 0,
    row = lines,
    height = 10,
    width = cols,
    style = 'minimal'
  }

  if self.preview_win and vim.api.nvim_win_is_valid(self.preview_win) then
    vim.api.nvim_win_set_buf(self.preview_win, buf)
    vim.api.nvim_win_set_config(self.preview_win, opts)
  else
    self.preview_win = vim.api.nvim_open_win(buf, false, opts)
    vim.api.nvim_win_set_option(self.preview_win, 'signcolumn', 'no')
  end
end

function Evaluator:new(attrs)
  attrs = attrs or {}
  assert(attrs.buf, 'You need to set buf for luapad')

  attrs.statusline = { status = 'ok' }
  attrs.active = true
  attrs.output = {}
  attrs.helper = {
    buf = attrs.buf,
    config = set_config
  }

  local obj = setmetatable(attrs, Evaluator)
  State.instances[attrs.buf] = obj
  return obj
end

function Evaluator:start()
  local on_change = vim.schedule_wrap(function()
    if not self.active then return true end
    if Config.eval_on_change then self:eval() end
  end)

  local on_detach = vim.schedule_wrap(function()
    self:close_preview()
    State.instances[self.buf] = nil
  end)

  vim.api.nvim_buf_attach(0, false, {
    on_lines = on_change,
    on_changedtick = on_change,
    on_detach = on_detach
  })

  vim.api.nvim_command('augroup LuapadAutogroup')
  vim.api.nvim_command('autocmd!')
  vim.api.nvim_command('au CursorMoved * lua require("luapad/cmds").on_cursor_moved()')
  vim.api.nvim_command('augroup END')
  vim.api.nvim_command(('augroup LuapadAutogroupNr%s'):format(self.buf))
  vim.api.nvim_command('autocmd!')
  vim.api.nvim_command(([[au CursorHold <buffer> lua require("luapad/cmds").on_cursor_hold(%s)]]):format(self.buf))
  vim.api.nvim_command(([[au CursorMoved <buffer> lua require("luapad/cmds").on_luapad_cursor_moved(%s)]]):format(self.buf))
  vim.api.nvim_command(([[au CursorMovedI <buffer> lua require("luapad/cmds").on_luapad_cursor_moved(%s)]]):format(self.buf))
  vim.api.nvim_command('augroup END')

  if Config.on_init then Config.on_init() end
  self:eval()
end

function Evaluator:finish()
  self.active = false
  vim.api.nvim_command(('augroup LuapadAutogroupNr%s'):format(self.buf))
  vim.api.nvim_command('autocmd!')
  vim.api.nvim_command('augroup END')
  State.instances[self.buf] = nil

  if vim.api.nvim_buf_is_valid(self.buf) then
    vim.api.nvim_buf_clear_namespace(self.buf, ns, 0, -1)
  end
  self:close_preview()
end

return Evaluator
