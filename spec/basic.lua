local t = require 'spec/test'

t.setup()

t.command('Luapad')
t.command('only')
t.input("iprint('')")
t.typein("<left><left>niesamowite!<esc>")

t.input('o')
t.input("print()")
t.typein("<left>'test 123 test'<right><cr><cr>")

t.input([[
function wow(...)<cr>
print({...})<cr>
end<cr>
wow()<left>
]])

t.typein([[1, 2, 3, 'aaa', 'bbb']])

t.input([[
<esc>o
local a = '' .. nil
]])

t.finish()
