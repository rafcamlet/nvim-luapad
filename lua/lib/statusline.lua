local Statusline = {}
local prefix = 'luapad__'

function Statusline:clear()
  self:set_msg()
  self:set_status()
end

function Statusline:set_msg(v)
  vim.api.nvim_set_var(prefix..'msg', v)
  self.msg = v
end

function Statusline:set_status(v)
  vim.api.nvim_set_var(prefix..'status', v or 'ok')
  self.status = v
end

function Statusline:lightline_status()
  if not vim.api.nvim_buf_get_option(0, 'filetype'):match('luapad') then
    return ''
  end

  local arr = {
    error = 'ERROR',
    syntax = 'SYNTAX',
    timeout = 'TIMEOUT'
  }
  return arr[self.status] or 'OK'
end

function Statusline:lightline_msg()
  if not vim.api.nvim_buf_get_option(0, 'filetype'):match('luapad') then
    return ''
  end
  return self.msg or ''
end

Statusline:clear()

return Statusline
