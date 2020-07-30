local t = require 'spec/test_helper'

test_iloop = t.new_group()

function test_iloop:test()
  t.set_lines(0,0, [[
while true do
  print('wow')
end
]])

  t.assert_str_contains(t.get_virtual_text(1)[1][1], 'wow')
  t.assert_equals(t.nvim('get_var', 'luapad_status'), 'timeout')
end
