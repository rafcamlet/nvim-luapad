-- local sleep = require'socket'.sleep

function sleep(n)
  os.execute("sleep " .. tonumber(n))
end

local address = 'localhost:3333'
local connection

local function split_keys(str)
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

local function setup()
  local arr = {
    'tmux kill-pane -a -t 0',
    'tmux split-window -h -d -p 30',
    ('tmux send-keys -t 1 "nvim --listen %s" C-m'):format(address)
  }
  for i,v in ipairs(arr) do
    os.execute(v)
  end
  sleep(1)
  connection = vim.api.nvim_call_function('sockconnect', {'tcp', address, {rpc = true}})
end

local function finish()
  vim.api.nvim_call_function('chanclose', {connection})
end

local function command(str)
  vim.api.nvim_call_function('rpcrequest', {connection, "nvim_command", str})
end

local function input(str)
  -- command('set insertmode')
  vim.api.nvim_call_function('rpcrequest', {connection, "nvim_input", str})
end

local function typein(str)
  -- command('set insertmode')
  for i, v in ipairs(split_keys(str)) do
    input(v)
    sleep(0.1)
  end
end

local function exec_lua(str)
  vim.api.nvim_call_function('rpcrequest', {connection, "nvim_exec_lua", str})
end

local function exec(str)
  vim.api.nvim_call_function('rpcrequest', {connection, "nvim_exec", str, false})
end

local function test(callback)
  setup()
  callback()
  finish()
end

return {
  setup = setup,
  finish = finish,
  input = input,
  typein = typein,
  command = command,
  test = test,
  sleep = sleep,
  exec_lua = exec_lua,
  exec = exec,
}
