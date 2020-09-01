local u = require 'luaunit'

local TestHelper = {
  address = 'localhost:3333'
}

function TestHelper.sleep(n)
  os.execute("sleep " .. tonumber(n))
end

function TestHelper.split_keys(str)
  local flag = false
  local result = {}
  local buf

  for c in str:gmatch"." do
    if c == '<' then
      buf = '<'
      flag = true
    elseif c == '>' then
      table.insert(result, buf .. '>')
      flag = false
    elseif flag then
      buf = buf .. c
    else
      table.insert(result, c)
    end
  end

  return result
end

function TestHelper.setup()
  local arr = {
    'tmux kill-pane -a -t 0',
    'tmux split-window -h -d -p 30',
    ('tmux send-keys -t 1 "nvim --listen %s" C-m'):format(TestHelper.address)
  }
  for _,v in ipairs(arr) do os.execute(v) end
  TestHelper.sleep(1)
  TestHelper.connection = vim.api.nvim_call_function(
    'sockconnect',
    {'tcp', TestHelper.address, {rpc = true}}
    )
end


function TestHelper.nvim(str, ...)
  return vim.api.nvim_call_function('rpcrequest', {TestHelper.connection, "nvim_" .. str, unpack({...})})
end

function TestHelper.finish()
  vim.api.nvim_call_function('chanclose', {TestHelper.connection})
end

function TestHelper.command(str)
  TestHelper.nvim('command', str)
end

function TestHelper.input(str)
  TestHelper.nvim('input', str)
end

function TestHelper.typein(str)
  -- command('set insertmode')
  for _, v in ipairs(TestHelper.split_keys(str)) do
    TestHelper.input(v)
    TestHelper.sleep(0.1)
  end
end

function TestHelper.exec_lua(str, args)
  return TestHelper.nvim('exec_lua', str, args or {})
end

function TestHelper.exec(str)
  TestHelper.nvim('exec', str, false)
end

function TestHelper.set_lines(start, finish, arr)
  if type(arr) == 'string' then arr = vim.split(arr, "\n") end
  TestHelper.nvim('buf_set_lines', 0, start, finish, false, arr)
end

function TestHelper.get_lines(start, finish)
  return TestHelper.nvim('buf_get_lines', 0, start, finish, false)
end

function TestHelper.get_virtual_text(line)
  local ns = vim.api.nvim_create_namespace('luapad_namespace')
  local result = TestHelper.nvim('buf_get_extmarks', 0, ns, {line, 0}, {line, -1}, { details = true })

  if #result == 0 then return end
  return result[1][#result[1]]["virt_text"][1]
end

function TestHelper.new_group()
  return {
    setUp = function()
      TestHelper.setup()
      TestHelper.command('Luapad')
      -- TestHelper.command('only')
    end,
    tearDown = function()
      TestHelper.finish()
    end
  }
end

setmetatable(TestHelper, { __index = u })

return TestHelper
