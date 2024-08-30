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
  if change==1 then
    if lefts[currChar] and (posChar==" " or posChar=="" or posChar==lefts[currChar]) then
      -- opening bracket inserted and not followed by text, should close it
      vim.api.nvim_buf_set_text(0, currRow-1, currCol, currRow-1, currCol, {lefts[currChar]})
    elseif quotes[currChar] and (posChar==" " or posChar=="" or posChar==currChar) then
      -- quote inserted and not followed by text, should close it or skip it
      -- numBool: 1 if posChar is different from currChar (should close quote), 0 otherwise
      numBool=(posChar~=currChar) and 1 or 0
      vim.api.nvim_buf_set_text(0, currRow-1, currCol, currRow-1, currCol+1-numBool, {currChar:rep(numBool)})
    elseif rights[currChar] and posChar==currChar then
      -- closing bracket inserted and next char is the same, should skip it
      vim.api.nvim_buf_set_text(0, currRow-1, currCol, currRow-1, currCol+1, {})
    end
  elseif change==-1 and (posChar==lefts[prevChar] or posChar==quotes[prevChar]) then
    -- opening bracket deleted and closing bracket is right after cursor, should delete it
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

