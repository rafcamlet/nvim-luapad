State = {
  instances = {}
}

State.current = function()
  return State.instances[vim.api.nvim_get_current_buf()]
end

return State
