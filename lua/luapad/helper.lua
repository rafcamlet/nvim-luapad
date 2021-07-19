local Config = require'luapad/config'.config
local set_config = require'luapad/config'.set_config

local Helper = {}

function Helper.set_lines(start, finish, replacement)
  if not vim.api.nvim_buf_is_valid(Helper.start_buf) then return end
  vim.api.nvim_buf_set_lines(Helper.start_buf, start, finish, false, replacement)
end

function Helper.add_hl(hl, line, start, finish)
  if not vim.api.nvim_buf_is_valid(Helper.start_buf) then return end
  vim.api.nvim_buf_add_highlight(Helper.start_buf, -1, hl, line, start, finish)
end

function Helper.clear()
  Helper.set_lines(0, -1, {})
end

function Helper.add(str, color)
  local lines = type(str) == 'string' and {str} or str

  if Helper._first then
    Helper.clear()
    Helper.set_lines(0, 1, lines)
    Helper._first = false
    if color and type(color) == 'string' then
      Helper.add_hl(color, 0, 0, -1)
    end
    return 0
  end

  Helper.set_lines(-1, -1, lines)
  local line_nr = vim.api.nvim_buf_line_count(Helper.start_buf) - 1

  if color and type(color) == 'string' then
    Helper.add_hl(color, line_nr, 0, -1)
  end

  return line_nr
end

function Helper.new(start_buf)
  Helper.start_buf = start_buf
  Helper._first = true
  return Helper
end

Helper.config = set_config

return Helper

-- Multiline add
-- setup function
-- internal error handling
