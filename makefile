test: plenary
	nvim --clean -u specs/minimal_init.vim --headless -c "lua require('plenary.test_harness').test_directory('specs/features/', {sequential=true})"

plenary:
	test -d "vendor/plenary" || git clone https://github.com/nvim-lua/plenary.nvim.git vendor/plenary/
