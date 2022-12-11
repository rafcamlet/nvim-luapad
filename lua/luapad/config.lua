local warning = [[[Luapad] Configure Luapad via vim globals is disabled. Please use \"require('luapad').config\".]]
local print_warn =  require('luapad.tools').print_warn

local deprecated_vars = {
  'luapad_count_limit',
  'luapad_error_indicator',
  'luapad_preview',
  'luapad_eval_on_change',
  'luapad_eval_on_move',
  'luapad_print_highlight',
  'luapad_error_highlight',
}

local function vim_config_disabled_warn()
  local warn_flag = false

  for _, var in ipairs(deprecated_vars) do
    local s, v = pcall(vim.api.nvim_get_var, var)
    if s and v then warn_flag = true end
  end

  if warn_flag then print_warn(warning) end
end

local Config = {
  on_init = nil,
  context = nil,

  preview = true,
  error_indicator = true,
  count_limit = 2 * 1e5,
  print_highlight = 'Comment',
  error_highlight = 'ErrorMsg',
  eval_on_move = false,
  eval_on_change = true,
  split_orientation = 'vertical',
  wipe = true
}

local function set_config(opts)
  opts = opts or {}
  for k, v in pairs(opts) do Config[k] = v end
end

return {
  config = Config,
  set_config = set_config,
  vim_config_disabled_warn = vim_config_disabled_warn
}
