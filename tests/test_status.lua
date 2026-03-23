
local h = require('tests/luapad_helpers')

local child

local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      child = h.new_child()
    end,
    post_case = function()
      child.stop()
    end,
  },
})

local function status()
  return child.lua("return require'luapad/statusline'.status()")
end

T['is "ok" when everything is ok'] = function()
  h.set_lines(child, 0, 0, "print('hello!')")
  MiniTest.expect.equality(status(), 'ok')
end

T['is "error" when the code is invalid'] = function()
  h.set_lines(child, 0, 0, "local a = '' .. nil")
  MiniTest.expect.equality(status(), 'error')
end

T['is "timeout" when there is an infinite loop'] = function()
  h.set_lines(child, 0, 0, "while true do print('wow') end")
  MiniTest.expect.equality(status(), 'timeout')
end

return T
