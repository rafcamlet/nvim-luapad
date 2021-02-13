local t = require 'spec/test_helper'

test_restore_context = t.new_group()

function test_restore_context.test()
  t.set_lines(0,0,[[
a = 5

function asdf()
  print(a)
end

asdf()
]])

  t.assert_true(#t.get_virtual_text(3) > 0)

  t.set_lines(2,5, {'', '', ''})
  t.command('1')
  t.set_lines(0,1, 'a = 30')

  t.assert_nil(t.get_virtual_text(3))
  t.assert_str_contains(t.exec_lua('return require"luapad/statusline".msg()'), "attempt to call global 'asdf'")
end
