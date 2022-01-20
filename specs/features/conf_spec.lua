local t = require 'specs.test_helper'

describe("config", function()

  t.setup()

  before_each(function()
    t.restart()
  end)

  local set_config = function(opts)
    t.exec_lua([[require'luapad'.config(...)]], {opts})
  end

  it('handel error_indicator setting', function ()
    local vt

    set_config({ error_indicator = true })
    t.set_lines(0, -1, 'local a = b + c')

    vt = t.get_virtual_text(0)

    assert.matches('attempt to perform arithmetic on.*a nil value', vt)


    set_config({ error_indicator = false })
    t.set_lines(0, -1, 'local d = e + f')

    vt = t.get_virtual_text(0)

    assert.is.Nil(vt)
  end)

  t.finish()
end)
