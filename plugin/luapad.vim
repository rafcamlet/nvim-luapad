" Maintainer:   Rafał Camlet <raf.camlet@gmail.com>
" License:      GNU General Public License v3.0

if exists('g:luapad_loaded') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

command! Luapad lua require'luapad'.init_luapad()
command! LuaRun lua require'luapad/run'()

function! Luapd_lua_complete (ArgLead, CmdLine, CursorPos) abort
  return luaeval('require"luapad/completion"(_A)', a:ArgLead)
endfunction

command! -complete=customlist,Luapd_lua_complete -nargs=1 Lua lua <args>

let &cpo = s:save_cpo
unlet s:save_cpo

let g:luapad_loaded = 1
