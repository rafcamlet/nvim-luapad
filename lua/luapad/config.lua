local function get_var(my_var_name)
  s, v = pcall(function()
    return vim.api.nvim_get_var(my_var_name)
  end)
  if s then return v end
end

local Config = {
  prefix = 'luapad_',
  bool_values = {
    preview = true,
    error_indicator = true
  },
  default = {
    preview = true,
    error_indicator = true,
    count_limit = 2 * 1e5
  },
  meta = {}
}

Config.meta.__index = function(self, key)
  local vim_key = self.prefix .. key

  if self.bool_values[key] then
    local v = get_var(vim_key)
    if v and tonumber(v) == 0 then return false end
    return v or self.default[key]
  else
    return get_var(vim_key) or self.default[key]
  end
end

setmetatable(Config, Config.meta)

return Config
