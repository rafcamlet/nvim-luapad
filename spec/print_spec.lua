local t = require 'spec/test_helper'

describe("print", function()

  t.setup()

  before_each(function()
    t.restart()
  end)

  it("prints virtual text", function()
    t.set_lines(0, 0,"print('incredible!')")
    local vt = t.get_virtual_text(0)

    assert.matches('incredible!', vt)
  end)


  it("prints tbl", function()
    t.set_lines(0, 0, "print(vim.split('wow|wow', '|'))")
    local vt = t.get_virtual_text(0)

    assert.matches('{ "wow", "wow" }', vt)
  end)


  it('prints function', function()
    t.set_lines(0, 0, [[
      function wow(...)
        print({...})
      end

      wow(1, 2, 3, 'aaa')
    ]])

    local vt = t.get_virtual_text(1)
    assert.matches('{ 1, 2, 3, "aaa" }', vt)
  end)


  it('prints fun called multiple times', function()
    t.set_lines(0,0, [[function asdf(a) print(a) end
    asdf('foo')
    asdf('bar')]])
    local vt = t.get_virtual_text(0)

    assert.matches('"foo" | "bar"', vt)
  end)


  it('prints loop', function ()
    t.set_lines(0,0, [[for i=0, 5 do print(i) end]])
    local vt = t.get_virtual_text(0)

    assert.matches('0 | 1 | 2 | 3 | 4 | 5', vt)
  end)


  it('print error messages', function()
    t.set_lines(0,0,[[ local a = '' .. nil ]])
    local vt = t.get_virtual_text(0)

    assert.matches('attempt to concatenate a nil value', vt)
  end)


  t.finish()
end)
