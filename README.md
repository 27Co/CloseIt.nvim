# CloseIt

Created by 27Co 202408  
A neovim plugin to automatically close brackets and quotes.

## Features

- Left brackets/quotes are automatically closed
- Cursor remains inside
- Typing the right bracket/quote moves cursor outside
- Deleting the left bracket/quote also deletes the right one
- Hitting enter indents the new line (with right bracket in another line)
- Ctrl+Backtick adds a code fence in insert mode

## Installation

### Using vim-plug

Install Lazy.nvim following the installation guide [here](https://lazy.folke.io/installation).

Then add this line where you add your plugins:

```lua
require("lazy").setup({
  spec = {
    -- here
    { "27Co/CloseIt.nvim" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
```

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
