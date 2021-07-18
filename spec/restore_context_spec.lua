local t = require 'spec/test_helper'

describe("context", function()

  before_each(function()
    t.setup()
  end)


  it('clears context after buffer change', function ()
    t.set_lines(0,0,[[
    a = 5

    function asdf()
      print(a)
    end

    asdf()
    ]])

    assert.matches('5', t.get_virtual_text(3))

    t.set_lines(2,5, {'', '', ''})
    t.command('1')
    t.set_lines(0,1, 'a = 30')

    assert.is_nil(t.get_virtual_text(3))

    local msg = t.exec_lua('return require"luapad/statusline".msg()')

    assert.matches('attempt to call global .asdf.', msg)
  end)

  t.finish()
end)
