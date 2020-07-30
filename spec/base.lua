local t = require 'spec/test_helper'

test_base = t.new_group()

function test_base:test_print()
  t.set_lines(0,0,"print('incredible!')")
  local virtual_txt = t.get_virtual_text(0)[1][1]

  t.assert_str_contains(virtual_txt, 'incredible!')
end

function test_base:test_print_with_split()
  t.set_lines(0,0, [[ print(vim.split('wow|wow', '|'))]])

  local expected_virtual_text = '{ "wow", "wow" }'
  local virtual_txt = vim.trim(t.get_virtual_text(0)[1][1])

  t.assert_str_contains(expected_virtual_text, virtual_txt)
end

function test_base:test_function_print()
  t.set_lines(0,0,[[
function wow(...)
  print({...})
end

wow(1, 2, 3, 'aaa')
]])

  local expected_virtual_text = '{ 1, 2, 3, "aaa" }'
  local received_virtual_text = t.get_virtual_text(1)[1][1]

  t.assert_str_contains(received_virtual_text, expected_virtual_text)
  t.assert_equals(t.nvim('get_var', 'luapad_status'), 'ok')
end

function test_base:test_error_msg()
  t.set_lines(0,0,[[ local a = '' .. nil ]])

  local virtual_txt = t.get_virtual_text(0)[1]

  t.assert_str_contains(virtual_txt[1], "attempt to concatenate a nil value")
  t.assert_str_contains(t.nvim('get_var', 'luapad_msg'), 'attempt to concatenate a nil value')

  t.assert_equals(t.nvim('get_var', 'luapad_status'), 'error')
  t.assert_equals(virtual_txt[2], "ErrorMsg")
end
