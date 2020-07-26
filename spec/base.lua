local t = require 'spec/test_lib'

t.setup()

t.command('Luapad')
t.command('only')

t.set_lines(0,0,"print('incredible!')")
t.assert(t.match(t.get_virtual_text(0)[1][1], 'incredible!'))

--

t.set_lines(1,1,"print(vim.split('wow|wow', '|'))")

local expected_virtual_text = '{ "wow", "wow" }'
local virtual_text = vim.trim(t.get_virtual_text(1)[1][1])

t.assert(t.eq(virtual_text, expected_virtual_text))

--

t.set_lines(3,3,[[
function wow(...)
  print({...})
end

wow(1, 2, 3, 'aaa')
]])
t.assert(t.match(t.get_virtual_text(4)[1][1], '{ 1, 2, 3, "aaa" }'))
t.assert(t.eq(t.nvim('get_var', 'luapad__status'), 'ok'))

--

t.set_lines(9,9,[[
local a = '' .. nil
]])

local virtual_text2 = t.get_virtual_text(9)[1]
t.assert(t.match(virtual_text2[1], "attempt to concatenate a nil value"))
t.assert(t.eq(virtual_text2[2], "ErrorMsg"))

t.assert(t.eq(t.nvim('get_var', 'luapad__status'), 'error'))
t.assert(t.match(t.nvim('get_var', 'luapad__msg'), 'attempt to concatenate a nil value'))

t.finish()
