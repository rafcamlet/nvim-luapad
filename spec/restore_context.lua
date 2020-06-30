local t = require 'spec/test'

t.setup()

t.command('Luapad')
t.command('only')
t.set_lines(0,0,[[
a = 5

function asdf()
  print(a)
end

asdf()
]])

assert(#t.get_virtual_text(3) > 0, 'It should have virutal text')

t.set_lines(2,5, {'', '', ''})
t.command('1')
t.set_lines(0,1, 'a = 30')

assert(#t.get_virtual_text(3) == 0, 'It should not have virutal text')
assert(
  t.nvim('get_var', 'luapad__msg'):match("attempt to call global 'asdf'"),
  'It should rise error'
  )

t.finish()
