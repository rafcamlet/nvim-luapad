local t = require 'spec/test'

t.setup()

t.command('Luapad')
t.command('only')
t.input("iprint('')")
t.typein("<left><left>asdf!'<esc>")

t.input('o<cr>')

t.input([[
while true do<cr>
print('x')<cr>
end
]])

t.finish()
