local Job = require'plenary.job'
local TestHelper = {
  address = vim.fn.tempname() .. '_luapad_nvim_socket',
  nr = 10
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
  if os.getenv("HEADLESS") == 'true' then return end
  local arr = {
    'tmux kill-pane -a -t 0',
    'tmux split-window -h -d -p 30'
  }

  if os.execute 'tmux has-session -t .1 2>/dev/null' ~= 0 then
    for _,v in ipairs(arr) do os.execute(v) end
  end
end


function TestHelper.restart()
  TestHelper.nr = TestHelper.nr + 1
  local address = TestHelper.address .. TestHelper.nr

  if os.getenv("HEADLESS") == 'true' then

    if TestHelper.job then TestHelper.job:shutdown() end

    TestHelper.job = Job:new({
      command = 'nvim',
      args = { '--clean', '-u', 'specs/minimal_init.vim', '--listen', address },
    }):start()
  else
    local cmd = ('tmux respawn-pane -k -t .1 "nvim --clean -u specs/minimal_init.vim --listen %s"'):format(address)
    os.execute(cmd)
  end

  repeat
    TestHelper.sleep(0.2)
    local ok, val = pcall(vim.fn.sockconnect, 'pipe', TestHelper.address .. TestHelper.nr, {rpc = true})
    TestHelper.connection = val
  until(ok)

  TestHelper.command('Luapad')
  TestHelper.command('only!')

end


function TestHelper.nvim(str, ...)
  return vim.rpcrequest(TestHelper.connection, "nvim_" .. str, unpack({...}))
end

function TestHelper.finish()
  pcall(vim.rpcrequest, TestHelper.connection, 'nvim_command', 'qa!')
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
  local ns = TestHelper.nvim('create_namespace', 'luapad_namespace')
  local result = TestHelper.nvim('buf_get_extmarks', 0, ns, {line, 0}, {line, -1}, { details = true })

  if #result == 0 then return end
  return result[1][#result[1]]["virt_text"][1][1]
end

function TestHelper.print(...)
  if #{...} > 1 then
    io.stdout:write(tostring(vim.inspect({...})))
  else
    io.stdout:write(tostring(vim.inspect(...)))
  end

  io.stdout:write("\n")
end

return TestHelper
