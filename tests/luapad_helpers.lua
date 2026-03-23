local M = {}

function M.new_child()
  local child = MiniTest.new_child_neovim()

  child.start({ '-u', 'tests/minimal_init.lua' })
  child.cmd('Luapad')
  child.cmd('only!')

  return child
end

function M.wait_for(child_fn, timeout, interval)
  timeout = timeout or 3000
  interval = interval or 50
  local deadline = vim.loop.now() + timeout
  while vim.loop.now() < deadline do
    local ok, result = pcall(child_fn)
    if ok and result then return result end
    vim.loop.sleep(interval)
  end
  error('wait_for: timed out')
end

local GET_VT_CODE = table.concat({
  'local line = ...',
  "local ns = vim.api.nvim_create_namespace('luapad_namespace')",
  'local marks = vim.api.nvim_buf_get_extmarks(0, ns, {line, 0}, {line, -1}, { details = true })',
  'if #marks == 0 then return nil end',
  'local vt = marks[1][#marks[1]].virt_text',
  'if not vt or #vt == 0 then return nil end',
  'return vt[1][1]',
}, '\n')

function M.get_virtual_text(child, line)
  local result = child.lua(GET_VT_CODE, { line })
  if result == vim.NIL then return nil end
  return result
end

function M.set_lines(child, start, finish, content)
  if type(content) == 'string' then
    content = vim.split(content, '\n')
  end
  child.api.nvim_buf_set_lines(0, start, finish, false, content)
  vim.loop.sleep(100)
end

function M.screen(child)
  local screenshot = child.get_screenshot()
  local lines = {}
  local width = 0

  for _, row in ipairs(screenshot.text) do
    local line = table.concat(row)
    table.insert(lines, line)
    if #line > width then width = #line end
  end
  local border = '┌' .. string.rep('─', width) .. '┐'

  print(border)

  for _, line in ipairs(lines) do
    print('│' .. line .. string.rep(' ', width - #line) .. '│')
  end

  print('└' .. string.rep('─', width) .. '┘')
end

return M
