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

### Configuration

| Name                    | Default value | Description                                                                                                                                                                                      |
| ---                     | ---           | ---                                                                                                                                                                                              |
| luapad_count_limit     | 200000        | Luapad uses count hook method to prevent infinite loops occurring during code execution. Setting count_limit too high will make Luapad laggy, setting it too low, may cause premature code termination. |
| luapad_error_indicator | 1             | Show virtual text with error message (except syntax or timeout errors)                                                                                                                          |
| luapad_preview         | 1             | Show floating output window on cursor hold. It's a good idea to set low update time. For example: `let &updatetime = 300` You can jump to it by `^w` `w`   |


Example configuration

```
let g:luapad_count_limit = 150000
let g:luapad_error_indicator = 0
let g:luapad_preview = 0
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

But you can also create your own integration, using exposed viml global variables: `g:luapad_status` and `g:luapad_msg`.

### Types of errors

Luapad separates errors into 3 categories:

| Error   | Description                                                                                                  |
| ---     | ---                                                                                                          |
| SYNTAX  | Content of buffer is not valid lua script (you will see it a lot during typing)                              |
| TIMEOUT | Interpreter has done more count instructions than luapad_count_limit, so there probably was a infinite loop |
| ERROR   | Execution logical errors                                                                                     |

### TODO
- [ ] Sandbox mode with potentially dangerous functions disabled


### Shameless self promotion

If you want to start your adventure with writing lua plugins and are you are wondering where to begin, you can take a look at the links below.

1. [How to write neovim plugins in Lua](https://www.2n.pl/blog/how-to-write-neovim-plugins-in-lua)
2. [How to make UI for neovim plugins in Lua](https://www.2n.pl/blog/how-to-make-ui-for-neovim-plugins-in-lua)
