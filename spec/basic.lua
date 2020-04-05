local t = require 'spec/test'

t.setup()
t.open('spec/fixtures/example.lua')

t.send("';LuapadThis' c-m")
t.sleep(1)
t.send("c-[ Go")
t.send([["print('')" left left]])
t.typein("niesamowite")
t.send("c-[")
t.sleep(0.5)

-- t.send("';Luapad' c-m")
-- t.send([["iprint('')" left left]])
-- t.typein("niesamowite")
