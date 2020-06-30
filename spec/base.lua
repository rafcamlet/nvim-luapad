local t = require 'spec/test'

t.setup()

t.command('Luapad')
t.command('only')

t.set_lines(0,0,"print('incredible!')")
assert(t.get_virtual_text(0)[1][1]:match('incredible!'))


t.set_lines(1,1,"print(vim.split('wow|wow', '|'))")
local expected_virtual_text = '{ "wow", "wow" }'
local virtual_text = vim.trim(t.get_virtual_text(1)[1][1])
assert(virtual_text == expected_virtual_text, 'vim.split not working')


t.set_lines(3,3,[[
function wow(...)
  print({...})
end

wow(1, 2, 3, 'aaa')
]])
assert(t.get_virtual_text(4)[1][1]:match('{ 1, 2, 3, "aaa" }'))


assert(t.nvim('get_var', 'luapad__status') == 'ok')
t.set_lines(9,9,[[
local a = '' .. nil
]])
local virtual_text = t.get_virtual_text(9)[1]
assert(virtual_text[1]:match("attempt to concatenate a nil value"))
assert(virtual_text[2] == "ErrorMsg")

assert(t.nvim('get_var', 'luapad__status') == 'error')
assert(t.nvim('get_var', 'luapad__msg'):match('attempt to concatenate a nil value'))

t.finish()
