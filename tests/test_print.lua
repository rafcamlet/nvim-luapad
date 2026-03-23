
local h = require('tests/luapad_helpers')

local child

local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      child = h.new_child()
    end,
    post_case = function()
      child.stop()
    end,
  },
})

T['prints virtual text'] = function()
  h.set_lines(child, 0, 0, "print('incredible!')")
  local vt = h.get_virtual_text(child, 0)

  MiniTest.expect.equality(vt ~= nil, true)
  assert(vt:find('incredible!'), 'expected "incredible!" in: ' .. tostring(vt))
end

T['prints table'] = function()
  h.set_lines(child, 0, 0, "print(vim.split('wow|wow', '|'))")
  local vt = h.get_virtual_text(child, 0)

  MiniTest.expect.equality(vt ~= nil, true)
  assert(vt:find('wow'), 'expected "wow" in: ' .. tostring(vt))
end

T['prints function result'] = function()
  h.set_lines(child, 0, 0, [[function wow(...) print({...}) end

wow(1, 2, 3, 'aaa')]])
  local vt = h.get_virtual_text(child, 0)

  MiniTest.expect.equality(vt ~= nil, true)
  assert(vt:find('1') and vt:find('aaa'), 'unexpected vt: ' .. tostring(vt))
end

T['prints function called multiple times'] = function()
  h.set_lines(child, 0, 0, [[function asdf(a) print(a) end
asdf('foo')
asdf('bar')]])
  local vt = h.get_virtual_text(child, 0)

  MiniTest.expect.equality(vt ~= nil, true)
  assert(vt:find('foo') and vt:find('bar'), 'unexpected vt: ' .. tostring(vt))
end

T['prints loop'] = function()
  h.set_lines(child, 0, 0, 'for i=0, 5 do print(i) end')
  local vt = h.get_virtual_text(child, 0)

  MiniTest.expect.equality(vt ~= nil, true)
  assert(vt:find('0') and vt:find('5'), 'unexpected vt: ' .. tostring(vt))
end

T['prints error messages'] = function()
  h.set_lines(child, 0, 0, "local a = '' .. nil")
  local vt = h.get_virtual_text(child, 0)

  MiniTest.expect.equality(vt ~= nil, true)
  assert(vt:find('attempt to concatenate'), 'unexpected vt: ' .. tostring(vt))
end

return T
