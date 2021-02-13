local t = require 'spec/test_helper'

test_config = t.new_group()

function test_config.test_error_indicator()
  t.exec('let g:luapad_error_indicator = 1')
  t.set_lines(0, -1, 'local a = b + c')
  local indicator = t.get_virtual_text(0)

  t.assert_not_nil(indicator)
  t.assert_str_contains(indicator[1], 'attempt to perform arithmetic on.*a nil value', true)

  t.exec('let g:luapad_error_indicator = 0')
  t.set_lines(0, -1, 'local d = e + f')

  indicator = t.get_virtual_text(0)
  t.assert_nil(indicator)
end
