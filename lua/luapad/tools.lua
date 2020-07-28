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
  parse_error = parse_error,
  tbl_keys = tbl_keys
}
