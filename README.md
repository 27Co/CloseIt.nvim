# CloseIt

Created by 27Co 202408
A neovim plugin to automatically close brackets and quotes.

## Features:

- Left brackets/quotes are automatically closed
- Cursor remains inside
- Typing the right bracket/quote moves cursor outside
- Deleting the left bracket/quote also deletes the right one
- Hitting enter indents the new line (with right bracket/quote in another line)

## Known bug:

- When cursor is moved in insert mode without text change (using arrow keys, for example), auto-close will not work properly.
