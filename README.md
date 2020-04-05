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

It is first version of this plugin (v0.0.1). All thoughts or/and error reports are welcome.

### Installation

With vim-plug:

```
    Plug "rafcamlet/nvim-luapad"
```

### Usage

Just run command `Luapad` for scratchpad in new window or `LuapadThis` to enable it in current.

### TODO
- [ ] Command to disable Luapad
- [ ] Sandbox mode with potentially dangerous functions disabled
- [x] Find way to handle infinite loops
- [ ] Describe infinite loops handling in readme
- [ ] Add configuration options
- [ ] Error indicator
