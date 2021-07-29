local t = require 'spec/test_helper'

describe("status", function()

  t.setup()

  before_each(function()
    t.restart()
  end)

  local status = function()
    return t.exec_lua('return require"luapad/statusline".status()')
  end

  it('is eq "ok" when evryting is ok', function ()
    t.set_lines(0,0, "print('hello!')")
    assert.equals('ok', status())
  end)


  it('is eq "error" when the code is invalid', function()
    t.set_lines(0,0, "local a = '' .. nil")

    assert.equals('error', status())
  end)


  it('is eq "timeout" if there was timeout', function()
    t.set_lines(0,0, "while true do print('wow') end")

    assert.equals('timeout', status())
  end)


  t.finish()
end)
