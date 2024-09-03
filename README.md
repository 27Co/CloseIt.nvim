# CloseIt

Created by 27Co 202408  
A neovim plugin to automatically close brackets and quotes.

## Features

- Left brackets/quotes are automatically closed
- Cursor remains inside
- Typing the right bracket/quote moves cursor outside
- Deleting the left bracket/quote also deletes the right one
- Hitting enter indents the new line (with right bracket in another line)

## Installation

### Using vim-plug

In init.vim file:

```vim
call plug#begin()
  " Add this line
  Plug '27Co/CloseIt'
call plug#end()
```

Or in init.lua file: wrap the above code in `vim.cmd` function.

```lua
vim.cmd([[
call plug#begin()
  " Add this line
  Plug '27Co/CloseIt'
call plug#end()
]])
```

Then run `:PlugInstall`.

## Known bug:

- Not working properly when cursor is moved in insert mode without text change (using arrow keys, for example).
