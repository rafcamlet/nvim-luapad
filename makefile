test:
	nvim --headless -u tests/minimal_init.lua -c "lua require('mini.test').setup(); MiniTest.run()"
