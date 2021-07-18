test:
	nvim --headless -c "luafile spec/run_specs.lua"
stable:
	# nvim-stable -u ~/.config/nvim/clean.vim --headless -c 'luafile spec/$(FILE).lua' -c 'lua os.exit(require("luaunit").LuaUnit.run())' -c quit -i NONE
