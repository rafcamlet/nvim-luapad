local State = require 'luapad/state'

local function status()
  if State.current() then return State.current().statusline.status end
end

local function msg()
  if State.current() then return State.current().statusline.msg end
end


local function lightline_status()
  if status() then return string.upper(status()) else return '' end
end

local function lightline_msg()
  return msg() or ''
end

return {
  status = status,
  msg = msg,
  lightline_msg = lightline_msg,
  lightline_status = lightline_status
}
