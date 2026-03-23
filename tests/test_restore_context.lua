
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

T['clears context after buffer change'] = function()
  h.set_lines(child, 0, 0, [[a = 5

function asdf()
  print(a)
end

asdf()]])

  local vt = h.get_virtual_text(child, 3)
  MiniTest.expect.equality(vt ~= nil, true)
  assert(vt:find('5'), 'expected "5" in: ' .. tostring(vt))

  -- Remove function body lines, change `a`
  child.api.nvim_buf_set_lines(0, 2, 5, false, { '', '', '' })
  child.api.nvim_buf_set_lines(0, 0, 1, false, { 'a = 30' })
  vim.loop.sleep(100)

  local vt2 = h.get_virtual_text(child, 3)
  MiniTest.expect.equality(vt2, nil)

  local msg = child.lua("return require'luapad/statusline'.msg()")
  MiniTest.expect.equality(msg ~= nil, true)
  assert(msg:find('attempt to call global') and msg:find('asdf'), 'unexpected msg: ' .. tostring(msg))
end

return T
