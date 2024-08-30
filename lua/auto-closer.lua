local auto_closer = {}

local currRow, currCol=unpack(vim.api.nvim_win_get_cursor(0))
local prevRow, prevCol
local currChar=""   -- character right before cursor (current)
local prevChar      -- character right before cursor (previous)
local posChar=""    -- character right after cursor (current)

local function update_pos()
  -- get_cursor: top right corner is (1, 0)
  prevRow, prevCol = currRow, currCol
  currRow, currCol = unpack(vim.api.nvim_win_get_cursor(0))
  prevChar = currChar
  if currCol==0 then
    currChar=""
  else
    currChar = vim.api.nvim_buf_get_text(0, currRow-1, currCol-1, currRow-1, currCol, {})[1]
  end
  posChar = vim.api.nvim_buf_get_text(0, currRow-1, currCol, currRow-1, currCol+1, {})[1]
end

local lefts={
  ["("]=")",
  ["["]="]",
  ["{"]="}",
  ["'"]="'",
  ['"']='"',
  ["`"]="`"
}

local rights={
  [")"]=true,
  ["]"]=true,
  ["}"]=true,
}

local function close_it()
  local change=currCol-prevCol
  if change==1 then
    if lefts[currChar] then
      vim.api.nvim_buf_set_text(0, currRow-1, currCol, currRow-1, currCol, {lefts[currChar]})
    elseif rights[currChar] and posChar==currChar then
      vim.api.nvim_buf_set_text(0, currRow-1, currCol, currRow-1, currCol+1, {})
    end
  elseif change==-1 and posChar==lefts[prevChar] then
    vim.api.nvim_buf_set_text(0, currRow-1, currCol, currRow-1, currCol+1, {})
  end
end

function auto_closer.setup()
  vim.api.nvim_create_autocmd({"TextChangedI", "InsertEnter"}, {
    pattern = "*",
    callback = update_pos
  })
  vim.api.nvim_create_autocmd("TextChangedI", {
    pattern = "*",
    callback = close_it
  })
end

return auto_closer

