" Maintainer:   Rafał Camlet <raf.camlet@gmail.com>
" License:      GNU General Public License v3.0

if exists('g:luapad__loaded') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

command! Luapad lua require'luapad'.init_luapad()
command! RunLua lua require'luapad'.run_lua()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:luapad__loaded = 1
