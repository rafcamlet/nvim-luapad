
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

T['error_indicator = true shows error vt'] = function()
  child.lua([[require'luapad'.config({ error_indicator = true })]])

  h.set_lines(child, 0, -1, 'local a = b + c')

  local vt = h.get_virtual_text(child, 0)

  MiniTest.expect.equality(vt ~= nil, true)
  assert(vt:find('attempt to perform arithmetic'), 'unexpected vt: ' .. tostring(vt))
end

T['error_indicator = false hides error vt'] = function()
  child.lua([[require'luapad'.config({ error_indicator = false })]])

  h.set_lines(child, 0, -1, 'local d = e + f')

  local vt = h.get_virtual_text(child, 0)
  MiniTest.expect.equality(vt, nil)
end

return T
