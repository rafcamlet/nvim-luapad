function sleep(n)
  os.execute("sleep " .. tonumber(n))
end

local function setup()
  local arr = {
    'tmux kill-pane -a -t 0',
    'tmux split-window -h',
    'tmux select-pane -t 0',
    'tmux send-keys -t 1 "nvim" C-m'
  }
  for i,v in ipairs(arr) do
    os.execute(v)
  end
  sleep(1)
end

local function send(str)
  os.execute('tmux send-keys -t 1 ' .. str )
end

local function typein(str)
  print('wow')
  for i=1,str:len() do
    local char = string.sub(str,i,i)

    sleep(0.1)
    os.execute('tmux send-keys -t 1 "' .. char .. '"' )
  end
end

local function open(file)
send("';e ".. file .. "' c-m")
end

return {
  sleep = sleep,
  setup = setup,
  send = send,
  typein = typein,
  open = open
}
