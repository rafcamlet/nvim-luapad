local t = require 'spec/test_lib'

local function is_indicator_visible()
  local indicator = t.get_virtual_text(0)[1]
  return indicator and indicator[1]:match('attempt to perform arithmetic on.*a nil value')
end

t.setup()

t.command('Luapad')
t.command('only')

t.exec('let g:luapad__error_indicator = 1')
t.set_lines(0, -1, 'local a = b + c')

t.assert(is_indicator_visible(), 'Error indicator is not visible!')

t.exec('let g:luapad__error_indicator = 0')
t.set_lines(0, -1, 'local d = e + f')

t.assert(not is_indicator_visible(), 'Error indicator is visible!')

t.finish()
