local auto_closer = {}

local prevCol

local function init_prevCol()
  prevCol=vim.api.nvim_win_get_cursor(0)[2]
end

local function check_forward()
  local currCol=vim.api.nvim_win_get_cursor(0)[2]
  if prevCol<currCol then
    prevCol=currCol
    return true
  else
    prevCol=currCol
    return false
  end
end

local brackets={
  ["("]=")",
  ["["]="]",
  ["{"]="}"
}

local quotes={
  ["'"]={true},
  ['"']={true},
  ["`"]={true}
}

local textChangedI=false

local function text_changed()
  textChangedI=true
end

local function close_it()
  if not textChangedI then
    return
  end
  textChangedI=false

  if not check_forward() then
    return
  end

  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local char = line:sub(col, col)
  if brackets[char] then
    vim.api.nvim_input(brackets[char].."<Left>")
  elseif quotes[char] then
    if quotes[char][1] then
        vim.api.nvim_input(char.."<Left>")
    end
    quotes[char][1]=not quotes[char][1]
  end
  return
end

function auto_closer.setup()
  vim.api.nvim_create_autocmd("InsertEnter", {
    pattern = "*",
    callback = init_prevCol
  })
  vim.api.nvim_create_autocmd("TextChangedI", {
    pattern = "*",
    callback = text_changed
  })
  vim.api.nvim_create_autocmd("CursorMovedI", {
    pattern = "*",
    callback = close_it
  })
end

return auto_closer

