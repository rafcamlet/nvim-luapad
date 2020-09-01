FILE ?= all

test:
	nvim --headless -c 'luafile spec/$(FILE).lua' -c 'lua os.exit(require("luaunit").LuaUnit.run())' -i NONE
stable:
	# nvim-stable -u ~/.config/nvim/clean.vim --headless -c 'luafile spec/$(FILE).lua' -c 'lua os.exit(require("luaunit").LuaUnit.run())' -c quit -i NONE
