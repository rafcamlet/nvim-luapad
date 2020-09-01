# Interactive neovim scratchpad for lua

Luapad runs your code in context with overwritten print function and displays the captured input as virtual text right there, where it was called - **in real time!**

![Luapad print gif](/gifs/luapad_new.gif)

![Luapad function gif](/gifs/luapad_colors.gif)

-------

Luapad adds Lua command (as native lua command extension) with deep function completion.

![Luapad nvim.split gif](/gifs/luapad_lua.gif)

-------

# WARNING!!!

Luapad evaluates every code that you put in it, so be careful what you type in, specially if it's system calls, file operations etc. Also calling functions like `nvim_open_win` isn't good idea, because every single change in buffer is evaluated (you will get new window with every typed char :D).

Luapad was designed to mess with small nvim lua code chunks. It probably will not work well with big "real" / "production" scripts.

All thoughts or/and error reports are welcome.

### Installation

With vim-plug:

```
    Plug "rafcamlet/nvim-luapad"
```

### Usage

Luapadd provides three different commands, that will help you with developing neovim plugins in lua:
  - **Luapad** - which open interactive scratch buffer with real time evaluation.
  - **LuaRun** - which run content of current buffer as lua script in new scope. You do not need to write file to disc or have to worry about overwriting functions in global scope. 
  - **Lua** - which is extension of native lua command with function completion.

From version 0.2 luapad will move towards lua api exposure. Several useful functions are already available.

```lua
require('luapad').init() -- same as Luapad command

-- Creates a new luapad instance and attaches it to the current buffer.
-- Optionally, you can pass to it a context table, the elements of which will be
-- available during the evaluation as "global" variables.
require('luapad').attach({
  context = { return_4 =  function() return 4 end }
})

-- Detach current luapad instance from buffer. Put simply, it just turns it off. :)
require('luapad').detach()

-- Toggle luapad in current buffer.
require('luapad').toggle({
  context = { return_4 =  function() return 4 end }
})

-- You can also create new luapad instance by yourself, which can be helpfull if you
-- want to attach it to a buffer different than the current one.
local buffer_handler = 5
require('luapad/evaluator'):new {
  buf = buffer_handler,
  context = { a = 'asdf' }
}:start()

-- luapad/run offers a run function (same as the LuaRun command) but allows you
-- to specify a context tbl
require 'luapad/run'.run {
  context = {
    print = function(str) print(string.upper(str)) end 
  }
}

-- If you turn off evaluation on change (and move) you can trigger it manualy by:
local luapad = require('luapad/evaluator'):new{buf = vim.api.nvim_get_current_buf()}
luapad:start()
luapad:eval()

-- You can always access current luapad instance by:
local luapad = require 'luapad/state'.current()
luapad:eval()

-- ...or iterate through all instances
for _, v in ipairs(require('luapad/state').instances) do
  v:eval()
end
```


### Configuration

There are currently two ways to configure luapad: via global viml variables (this method will be deprecated in next version) and via the ``luapad.config`` function (preferred way). The configuration is global and affects all luapad instances (but this is likely to change in future versions). All viml variables uses `luapad_`  prefix, so `count_limit` option will be `g:luapad_count_limit`. Config via lua has priority over viml.


| Name                    | Lua default value | Vim default value        | Description                                                                                                                                                                                             |
| ---                     | ---               | ---                  | ---                                                                                                                                                                                                     |
| count_limit             | 200000            | 200000               | Luapad uses count hook method to prevent infinite loops occurring during code execution. Setting count_limit too high will make Luapad laggy, setting it too low, may cause premature code termination. |
| error_indicator         | true              | 1                    | Show virtual text with error message (except syntax or timeout errors)                                                                                                                                  |
| preview                 | true              | 1                    | Show floating output window on cursor hold. It's a good idea to set low update time. For example: `let &updatetime = 300` You can jump to it by `^w` `w`                                                |
| eval_on_change          | true              | 1                    | Evaluate buffer content when it changes |
| eval_on_move            | false             | 0                    | Evaluate all luapad buffers when the cursor moves|
| print_highlight         | 'Comment'         | 'Comment'            | Highlight group used to coloring luapad print output                                                                                                                                                    |
| error_highlight         | 'ErrorMsg'        | 'ErrorMsg'           | Highlight group used to coloring luapad error indicator                                                                                                                                                 |
| on_init                 | nil               | can't be set by viml | Callback function called after creating new luapad instance                                                                                                                                                                                                          |
| context                 | {}                | can't be set by viml | The default context tbl in which luapad buffer is evaluated. Its properties will be available in buffer as "global" variables.




Example configuration

``````lua
-- lua
require 'luapad'.config{
  count_limit = 150000,
  error_indicator = false,
  eval_on_move = true,
  error_highlight = 'WarningMsg',
  on_init = function()
    print 'Hello from Luapad!'
  end,
  context = {
    the_answer = 42,
    shout = function(str) return(string.upper(str) .. '!') end
  }
}
``````

```
" viml
let g:luapad_count_limit = 150000
let g:luapad_error_indicator = 0
let g:luapad_preview = 0
let g:luapad_error_highlight = 'WarningMsg'

hi MyCustomLuapadOutputColor ctermfg=2
let g:luapad_print_highlight = 'MyCustomLuapadOutputColor'
```

### Statusline

Luapad has ready to use lightline function_components.

Example lightline configuration:

```viml
let g:lightline = {
      \ 'active': {
      \   'left': [
      \     [ 'mode', 'paste' ],
      \     [ 'readonly', 'filename', 'modified' ],
      \     [ 'luapad_msg']
      \   ],
      \ 'right': [
      \   ['luapad_status'],
      \   ['lineinfo'],
      \   ['percent'],
      \ ],
      \ },
      \ 'component_function': {
      \   'luapad_msg': 'luapad#lightline_msg',
      \   'luapad_status': 'luapad#lightline_status',
      \ },
      \ }
```

But you can also create your own integration, using lua functions  `require'luapad/statusline'.status()` and `require'luapad/statusline'.msg()`.


### Types of errors

Luapad separates errors into 3 categories:

| Error   | Description                                                                                                  |
| ---     | ---                                                                                                          |
| SYNTAX  | Content of buffer is not valid lua script (you will see it a lot during typing)                              |
| TIMEOUT | Interpreter has done more count instructions than luapad_count_limit, so there probably was a infinite loop |
| ERROR   | Execution logical errors                                                                                     |


### Changelog
#### v0.2

- Better native lsp integration (now you should have lsp completion in luapad buffers)
- Enable creation of multiple luapads instances
- Allow luapad to be attached to an existing buffer
- Add on_init callback
- Allow providing evaluation context for luapad buffers
- Allow configure luapad via lua
- Add `eval_on_move` and `eval_on_change` settings
- Expose luapad lua api
- Replace `g:luapad_status` and `g:luapad_msg` variables by `status()` and `msg()` lua functions.


### TODO
- [ ] Sandbox mode with potentially dangerous functions disabled


### Shameless self promotion

If you want to start your adventure with writing lua plugins and are you are wondering where to begin, you can take a look at the links below.

1. [How to write neovim plugins in Lua](https://www.2n.pl/blog/how-to-write-neovim-plugins-in-lua)
2. [How to make UI for neovim plugins in Lua](https://www.2n.pl/blog/how-to-make-ui-for-neovim-plugins-in-lua)
