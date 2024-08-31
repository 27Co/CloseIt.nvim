local CloseIt={}

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
}

local rights={
  [")"]=true,
  ["]"]=true,
  ["}"]=true,
}

local quotes={
  ["'"]="'",
  ['"']='"',
  ["`"]="`"
}

local function close_it()
  local change=currCol-prevCol
  -- 1 if single character inserted
  -- -1 if single character deleted
  if change==1 then
    if lefts[currChar] and (posChar==" " or posChar=="" or posChar==lefts[currChar]) then
      -- [left] inserted, followed by [space|empty|right] (close it)
      vim.api.nvim_buf_set_text(0, currRow-1, currCol, currRow-1, currCol, {lefts[currChar]})
    elseif rights[currChar] and posChar==currChar then
      -- [right] inserted, followed by [right] (skip it)
      vim.api.nvim_buf_set_text(0, currRow-1, currCol, currRow-1, currCol+1, {})
    elseif quotes[currChar] and (posChar==" " or posChar=="" or posChar==quotes[currChar]) then
      -- [quote] inserted, followed by [space|empty|quote]
      numBool=(posChar~=currChar) and 1 or 0
      -- 1 if followed by [space|empty] (close it)
      -- 0 if followed by [quote] (skip it)
      vim.api.nvim_buf_set_text(0, currRow-1, currCol, currRow-1, currCol+1-numBool, {currChar:rep(numBool)})
    end
  elseif change==-1 and (posChar==lefts[prevChar] or posChar==quotes[prevChar]) then
    -- [left/quote] deleted, followed by [right/quote] (delete it)
    vim.api.nvim_buf_set_text(0, currRow-1, currCol, currRow-1, currCol+1, {})
  end
end

function CloseIt.setup()
  vim.api.nvim_create_autocmd({"TextChangedI", "InsertEnter"}, {
    pattern = "*",
    callback = update_pos
  })
  vim.api.nvim_create_autocmd("TextChangedI", {
    pattern = "*",
    callback = close_it
  })
end

return CloseIt

