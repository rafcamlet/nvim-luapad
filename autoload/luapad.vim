function! luapad#lightline_status()
  return luaeval("require'luapad/statusline':lightline_status()")
endfunction

function! luapad#lightline_msg()
  return luaeval("require'luapad/statusline':lightline_msg()")
endfunction
