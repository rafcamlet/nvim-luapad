local t = require 'spec/test_lib'

t.setup()
t.command('Luapad')
t.command('only')

t.set_lines(0,0, [[
while true do
  print('wow')
end
]])
t.assert(t.match(t.get_virtual_text(1)[1][1], 'wow'))
t.assert(t.eq(t.nvim('get_var', 'luapad__status'), 'timeout'))

t.finish()
