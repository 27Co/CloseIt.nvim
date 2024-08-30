local auto_closer = {}

local currRow, currCol=unpack(vim.api.nvim_win_get_cursor(0))
local prevRow, prevCol
local currChar=""
local prevChar
local posChar=""

local function update_pos()
    print("--------------------")
    -- get_cursor: top right corner is (1, 0)
    prevRow, prevCol = currRow, currCol
    currRow, currCol = unpack(vim.api.nvim_win_get_cursor(0))
    prevChar = currChar
    posChar = vim.api.nvim_buf_get_text(0, currRow-1, currCol, currRow-1, currCol+1, {})[1]
    if currCol==0 then
        print("start of line")
        currChar=""
    else
        print("getting char at row:", currRow-1, "column:["..currCol-1, currCol.."]")
        currChar = vim.api.nvim_buf_get_text(0, currRow-1, currCol-1, currRow-1, currCol, {})[1]
    end
    print("cursor at row:", currRow, "column:", currCol)
    print("prevChar:<"..prevChar..">")
    print("currChar:<"..currChar.."> at row:", currRow-1, "column:["..currCol-1, currCol.."]")
end

local brackets={
  ["("]=")",
  ["["]="]",
  ["{"]="}"
}

--[[
local quotes={
  ["'"]={true},
  ['"']={true},
  ["`"]={true}
}
--]]

local function close_it()
  print("~~~~~~~~~~~~~~~~~~~~")
  -- check single character change
  local singleAdd, singleRmv=false, false
  if currRow==prevRow then
    print("check:", prevCol, "->", currCol)
    if currCol==prevCol+1 then
      -- insert a char
      singleAdd=true
    elseif currCol==prevCol-1 then
      -- delete a char
      singleRmv=true
    end
  end

  -- if not, do nothing
  if not (singleAdd or singleRmv) then
    print("singleAdd:", singleAdd, "singleRmv:", singleRmv)
    print("not singleAdd or singleRmv")
    return
  end

  -- from here, a single character is either added or removed
  if singleAdd then
    print("singleAdd")
    if brackets[currChar] then
      vim.api.nvim_input(brackets[currChar].."<Left>")
    --[[
    elseif quotes[currChar] then
      if quotes[currChar][1] then
        vim.api.nvim_input(currChar.."<Left>")
      end
      quotes[currChar][1]=not quotes[currChar][1]
    --]]
    end
  elseif singleRmv then
    print("singleRmv")
    if posChar==brackets[prevChar] then
      vim.api.nvim_input("<Del>")
    --[[
    elseif quotes[prevChar] then
      if quotes[prevChar][1] then
        vim.api.nvim_input("<Del>")
      end
      quotes[prevChar][1]=not quotes[prevChar][1]
    --]]
    end
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

