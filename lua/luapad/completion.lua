local tbl_keys = require'luapad/tools'.tbl_keys

local function completion_search(s_arr, prefix, r_arr)
  if #s_arr == 0 then return end
  if not r_arr then r_arr = _G end

  local head = table.remove(s_arr, 1)

  if type(r_arr[head]) == 'table' then
    prefix = prefix .. head .. '.'
    return completion_search(s_arr, prefix, r_arr[head])
  end

  local result = {}
  for _, v in ipairs(tbl_keys(r_arr)) do
    local regex = '^' .. string.gsub(head, '%*', '.*')
    if v:find(regex) then table.insert(result, prefix .. v) end
  end

  return result
end

function completion(line)
  local index = line:find('[%w._*]*$')
  local cmd = line:sub(index)
  local prefix = line:sub(1, index - 1)

  local arr = vim.split(cmd, '.', true)

  return completion_search(arr, prefix)
end

return completion
