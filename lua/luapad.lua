local Config = require'luapad/config'
local Evaluator = require'luapad/evaluator'
local State = require 'luapad/state'
local path = require 'luapad/tools'.path
local create_file = require 'luapad/tools'.create_file
local remove_file = require 'luapad/tools'.remove_file

local GCounter = 0

local function init()
  GCounter = GCounter + 1
  local file_path = path('tmp', 'Luapad_' .. GCounter .. '.lua')

  -- hacky solution to deal with native lsp
  create_file(file_path)
  vim.api.nvim_command('botright vsplit ' .. file_path)
  remove_file(file_path)

  local buf = vim.api.nvim_get_current_buf()

  Evaluator:new{buf = buf}:start()

  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'lua')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_command('au QuitPre <buffer> set nomodified')
end

local function attach(opts)
  if State.current() then return end
  opts = opts or {}
  opts.buf = vim.api.nvim_get_current_buf()
  Evaluator:new(opts):start()
end

local function detach()
  if State.current() then State.current():finish() end
end

local function toggle(opts)
  if State.current() then detach() else attach(opts) end
end

return {
  init = init,
  attach = attach,
  detach = detach,
  toggle = toggle,
  config = Config.config,
  current = State.current,
  version = '0.2'
}
