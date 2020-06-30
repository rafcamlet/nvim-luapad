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
  for _,v in ipairs(arr) do os.execute(v) end
  sleep(1)
  connection = vim.api.nvim_call_function('sockconnect', {'tcp', address, {rpc = true}})
end


local function nvim(str, ...)
  return vim.api.nvim_call_function('rpcrequest', {connection, "nvim_" .. str, unpack({...})})
end

local function finish()
  vim.api.nvim_call_function('chanclose', {connection})
  print('Connection closed')
end

local function command(str)
  nvim('command', str)
end

local function input(str)
  nvim('input', str)
end

local function typein(str)
  -- command('set insertmode')
  for _, v in ipairs(split_keys(str)) do
    input(v)
    sleep(0.1)
  end
end

local function exec_lua(str)
  nvim('exec_lua', str)
end

local function exec(str)
  nvim('exec', str, false)
end

local function set_lines(start, finish, arr)
  if type(arr) == 'string' then arr = vim.split(arr, "\n") end
  nvim('buf_set_lines', 0, start, finish, false, arr)
end

local function get_lines(start, finish)
  return nvim('buf_get_lines', 0, start, finish, false)
end

local function get_virtual_text(line)
  return nvim('buf_get_virtual_text', 0, line)
end

return {
  setup = setup,
  finish = finish,
  input = input,
  typein = typein,
  command = command,
  sleep = sleep,
  exec_lua = exec_lua,
  exec = exec,
  set_lines = set_lines,
  get_lines = get_lines,
  nvim = nvim,
  get_virtual_text = get_virtual_text
}
