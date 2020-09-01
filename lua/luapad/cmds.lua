local State = require('luapad/state')
local Config = require'luapad/config'

local function on_cursor_hold(buf)
  if Config.preview then State.instances[buf]:preview() end
end

local function on_luapad_cursor_moved(buf)
  State.instances[buf]:close_preview()
end

local function on_cursor_moved()
  if Config.eval_on_move then
    for _, v in pairs(State.instances) do v:eval() end
  end
end

return {
  on_cursor_hold = on_cursor_hold,
  on_cursor_moved = on_cursor_moved,
  on_luapad_cursor_moved = on_luapad_cursor_moved,
}
