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
  local str = debug.getinfo(2, "S").source:sub(2)
  root = str:match(("(.*)lua%sluapad.lua"):format(sep))
  return root .. table.concat({...}, (sep))
end

local function create_file(f)
  local fd = vim.loop.fs_open(f, "w", 438)
  vim.loop.fs_close(fd)
end

local function remove_file(f)
  vim.loop.fs_unlink(f)
end

return {
  parse_error = parse_error,
  tbl_keys = tbl_keys,
  path = path,
  create_file = create_file,
  remove_file = remove_file
}
