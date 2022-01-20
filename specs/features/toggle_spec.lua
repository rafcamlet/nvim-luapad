local t = require 'specs.test_helper'

describe("toggle", function()

  t.setup()

  before_each(function()
    t.restart()
  end)


  it('toggles luapad', function ()
    t.command 'tabnew'
    t.set_lines(0,0, [[
    local a, b
    a = 10
    b = 20
    print(a + b)
    ]])

    assert.is_nil(t.get_virtual_text(3))
    t.exec_lua('require"luapad".toggle()')

    assert.matches('30', t.get_virtual_text(3))

    t.exec_lua('require"luapad".toggle()')

    assert.is_nil(t.get_virtual_text(3))

    t.exec_lua('require"luapad".toggle()')
    t.set_lines(1,2, {'a = 20'})

    assert.matches('40', t.get_virtual_text(3))
  end)

  t.finish()
end)
