local function get_var(my_var_name, default_value)
  s, v = pcall(function()
    return vim.api.nvim_get_var(my_var_name)
  end)
  if s then return v else return default_value end
end

local function get_bool_var(my_var_name, default_value)
  local var = get_var(my_var_name, default_value)
  if var and tonumber(var) == 0 then return false end
  return var
end

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

return {
  get_var = get_var,
  parse_error = parse_error,
  get_bool_var = get_bool_var,
  tbl_keys = tbl_keys
}
