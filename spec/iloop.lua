local t = require 'spec/test'

t.setup()
t.open('spec/fixtures/iloop.lua')

t.send("';LuapadThis' c-m")

-- t.sleep(1)
-- t.send("c-[ Go")
-- t.send([["print('')" left left]])
-- t.typein("test test test 123")
