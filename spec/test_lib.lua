-- local sleep = require'socket'.sleep

local TestLib = {
  address = 'localhost:3333'
}

function TestLib.sleep(n)
  os.execute("sleep " .. tonumber(n))
end

function TestLib.split_keys(str)
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

function TestLib.setup()
  local arr = {
    'tmux kill-pane -a -t 0',
    'tmux split-window -h -d -p 30',
    ('tmux send-keys -t 1 "nvim --listen %s" C-m'):format(TestLib.address)
  }
  for _,v in ipairs(arr) do os.execute(v) end
  TestLib.sleep(1)
  TestLib.connection = vim.api.nvim_call_function(
    'sockconnect',
    {'tcp', TestLib.address, {rpc = true}}
    )
end


function TestLib.nvim(str, ...)
  return vim.api.nvim_call_function('rpcrequest', {TestLib.connection, "nvim_" .. str, unpack({...})})
end

function TestLib.finish()
  vim.api.nvim_call_function('chanclose', {TestLib.connection})
end

function TestLib.command(str)
  TestLib.nvim('command', str)
end

function TestLib.input(str)
  TestLib.nvim('input', str)
end

function TestLib.typein(str)
  -- command('set insertmode')
  for _, v in ipairs(TestLib.split_keys(str)) do
    TestLib.input(v)
    TestLib.sleep(0.1)
  end
end

function TestLib.exec_lua(str)
  TestLib.nvim('exec_lua', str)
end

function TestLib.exec(str)
  TestLib.nvim('exec', str, false)
end

function TestLib.set_lines(start, finish, arr)
  if type(arr) == 'string' then arr = vim.split(arr, "\n") end
  TestLib.nvim('buf_set_lines', 0, start, finish, false, arr)
end

function TestLib.get_lines(start, finish)
  return TestLib.nvim('buf_get_lines', 0, start, finish, false)
end

function TestLib.get_virtual_text(line)
  return TestLib.nvim('buf_get_virtual_text', 0, line)
end

function TestLib.debug(msg)
  local data = debug.getinfo(2, 'Sl')
  print(('%s:%d: %s'):format(
      data.short_src,
      data.currentline,
      msg
    ))
end

function TestLib.assert(result, msg)
  if result then return end
  local data = debug.getinfo(2, 'Sl')
  print(('%s:%d: %s'):format(
      data.short_src,
      data.currentline,
      msg
    ))
end

function TestLib.eq(left, right)
  if left == right then return true end
  return false, "Expected: " .. vim.inspect(left) .. ' to be equal: ' .. vim.inspect(right)
end

function TestLib.match(left, right)
  if tostring(left):match(tostring(right)) then return true end
  return false, "Expected: " .. vim.inspect(left) .. ' to match: ' .. vim.inspect(right)
end

return TestLib
