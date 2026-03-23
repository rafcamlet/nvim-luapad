
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

T['toggles luapad on and off'] = function()
  child.cmd('tabnew')
  h.set_lines(child, 0, 0, [[local a, b
a = 10
b = 20
print(a + b)]])

  local vt = h.get_virtual_text(child, 3)
  MiniTest.expect.equality(vt, nil)

  child.lua([[require'luapad'.toggle()]])
  vim.loop.sleep(100)
  local vt2 = h.get_virtual_text(child, 3)
  MiniTest.expect.equality(vt2 ~= nil, true)
  assert(vt2:find('30'), 'expected "30" in: ' .. tostring(vt2))

  child.lua([[require'luapad'.toggle()]])
  vim.loop.sleep(100)
  local vt3 = h.get_virtual_text(child, 3)
  MiniTest.expect.equality(vt3, nil)

  child.lua([[require'luapad'.toggle()]])
  child.api.nvim_buf_set_lines(0, 1, 2, false, { 'a = 20' })
  vim.loop.sleep(100)

  local vt4 = h.get_virtual_text(child, 3)
  MiniTest.expect.equality(vt4 ~= nil, true)
  assert(vt4:find('40'), 'expected "40" in: ' .. tostring(vt4))
end

return T
