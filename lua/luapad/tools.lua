local function parse_error(str)
  return str:match("%[string.*%]:(%d*): (.*)")
end

local function tbl_keys(t)
  local keys = {}
  for k, _ in pairs(t) do
    table.insert(keys, k)
  end
  return keys
end

local sep = vim.api.nvim_call_function('has', {'win32'}) == 0 and '/' or '\\'

local function path(...)
  return vim.api.nvim_eval('tempname()') .. '_Luapad.lua'
end

local function create_file(f)
  local fd = vim.loop.fs_open(f, "w", 438)
  vim.loop.fs_close(fd)
end

local function remove_file(f)
  vim.loop.fs_unlink(f)
end

local function print_warn(str)
  vim.api.nvim_command('echohl WarningMsg')
  vim.api.nvim_command(('echomsg "%s"'):format(str))
  vim.api.nvim_command('echohl None')
end

local function print_error(str)
  vim.api.nvim_command('echohl Error')
  vim.api.nvim_command(('echomsg "%s"'):format(str))
  vim.api.nvim_command('echohl None')
end

local function table_find(tbl, predicate)
  for i, v in ipairs(tbl) do
    if predicate(v) then
      return v, i
    end
  end
  return nil
end


return {
  parse_error = parse_error,
  tbl_keys = tbl_keys,
  path = path,
  create_file = create_file,
  remove_file = remove_file,
  print_warn = print_warn,
  print_error = print_error,
  table_find = table_find
}
