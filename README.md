# Interactive neovim scratchpad for lua

Luapad run your code in context with overwritten print function and display the captured input as virtual text right there, where it was called - **in real time!**

![Luapad print gif](/gifs/luapad-print.gif)

-------

![Luapad function gif](/gifs/luapad-function.gif)

-------

You can use build-in neovim functions

![Luapad nvim.split gif](/gifs/luapad-split.gif)


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

Just run command `Luapad`.

### Configuration

| Name                    | Default value | Description                                                                                                                                                                                      |
| ---                     | ---           | ---                                                                                                                                                                                              |
| luapad_count_limit     | 200000        | Luapad uses count hook method to preventing infinite loops during code execution. Setting count_limit too high will make Luapad laggy, setting it too low, may cause premature code termination. |
| luapad_error_indicator | 1             | Show virtual text with error message (except syntax or timeout errors)                                                                                                                          |

Example configuration

```
let g:luapad_count_limit = 150000
let g:luapad_error_indicator = 0
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

Luapad divides errors on 3 categories:

| Error   | Description                                                                                                  |
| ---     | ---                                                                                                          |
| SYNTAX  | Content of buffer is not valid lua script (you will see it a lot during typing)                              |
| TIMEOUT | Interpreter has done more count instructions than luapad_count_limit, so there probably was a infinite loop |
| ERROR   | Execution logical errors                                                                                     |

### TODO
- [ ] Sandbox mode with potentially dangerous functions disabled
- [x] Find way to handle infinite loops
- [x] Add configuration options
- [x] Error indicator
- [x] Lightline integration
- [x] Restore context between each code evaluation
- [ ] Update gifs
- [ ] Doc for LuaRun
- [ ] Doc for Lua
- [ ] Doc for preview
