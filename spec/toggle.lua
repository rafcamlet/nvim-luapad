local t = require 'spec/test_helper'

test_toggle = t.new_group()

function test_toggle.test()
  t.command 'tabnew'
  t.set_lines(0,0, [[
  local a, b
  a = 10
  b = 20
  print(a + b)
  ]])
  t.assert_nil(t.get_virtual_text(4))
  t.exec_lua('require"luapad".toggle()')
  t.assert_str_contains(t.get_virtual_text(3)[1], '30')
  t.exec_lua('require"luapad".toggle()')
  t.assert_nil(t.get_virtual_text(4))
  t.exec_lua('require"luapad".toggle()')
  t.set_lines(1,2, {'a = 20'})
  t.assert_str_contains(t.get_virtual_text(3)[1], '40')
end
