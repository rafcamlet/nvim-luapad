local set_config = require'luapad.config'.set_config
local config = require'luapad.config'.config
local vim_config_disabled_warn = require'luapad.config'.vim_config_disabled_warn

local Evaluator = require'luapad.evaluator'
local State = require 'luapad.state'
local path = require 'luapad.tools'.path
local create_file = require 'luapad.tools'.create_file
local remove_file = require 'luapad.tools'.remove_file

local GCounter = 0

local function init()
  vim_config_disabled_warn()

  GCounter = GCounter + 1
  local file_path = path('tmp', 'Luapad_' .. GCounter .. '.lua')

  -- hacky solution to deal with native lsp
  remove_file(file_path)
  create_file(file_path)

  local split_orientation = 'vsplit'
  if config.split_orientation == 'horizontal' then
      split_orientation = 'split'
  end
  vim.api.nvim_command('botright ' .. split_orientation .. ' ' .. file_path)

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
  config = set_config,
  setup = set_config,
  current = State.current,
  version = '0.3'
}
