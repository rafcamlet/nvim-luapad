FILE ?= all

test:
	nvim --headless -c 'luafile spec/$(FILE).lua' -c quit -i NONE
stable:
	nvim-stable -u ~/.config/nvim/clean.vim --headless -c 'luafile spec/$(FILE).lua' -c quit -i NONE
