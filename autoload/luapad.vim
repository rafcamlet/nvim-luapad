function! luapad#lightline_status()
  return luaeval("require'lib/statusline':lightline_status()")
endfunction

function! luapad#lightline_msg()
  return luaeval("require'lib/statusline':lightline_msg()")
endfunction
