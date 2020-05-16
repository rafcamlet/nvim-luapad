local t = require 'spec/test'

t.setup()

t.command('Luapad')
t.command('only')

t.exec('let g:luapad__error_indicator = 1')
t.input('ilocal a = b + c<esc>')
t.sleep(1)
t.exec('let g:luapad__error_indicator = 0')
t.input('olocal a = b + c<esc>')


t.command('Luapad')
t.sleep(0.5)
t.command('set insertmode')
t.input([[
  local count = 0<cr>
  while true do<cr>
    count = count + 1<cr>
    print(count)<cr>
  end
]])
t.sleep(1)
t.exec('let g:luapad__count_limit = 10000')
t.input('<cr>')
t.sleep(1)
t.exec('let g:luapad__count_limit = 200000')
t.input('<cr>')

t.finish()
