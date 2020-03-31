" Maintainer:   Rafał Camlet <raf.camlet@gmail.com>
" License:      GNU General Public License v3.0

if exists('g:loaded_nvim_luapad') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

command! Luapad     lua require'luapad'.init_luapad(true)
command! LuapadThis lua require'luapad'.init_luapad(false)

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_nvim_luapad = 1
