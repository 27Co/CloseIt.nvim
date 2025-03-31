local vim = vim
local currRow, currCol = unpack(vim.api.nvim_win_get_cursor(0))
local prevRow, prevCol
local currChar = "" -- character right before cursor (current)
local prevChar -- character right before cursor (previous)
local posChar = "" -- character right after cursor (current)

local function update_pos()
	-- get_cursor: top right corner is (1, 0)
	prevRow, prevCol = currRow, currCol
	currRow, currCol = unpack(vim.api.nvim_win_get_cursor(0))
	prevChar = currChar
	if currCol == 0 then
		currChar = ""
	else
		currChar = vim.api.nvim_buf_get_text(0, currRow - 1, currCol - 1, currRow - 1, currCol, {})[1]
	end
	posChar = vim.api.nvim_buf_get_text(0, currRow - 1, currCol, currRow - 1, currCol + 1, {})[1]
end

local lefts = {
	["("] = ")",
	["["] = "]",
	["{"] = "}",
}

local rights = {
	[")"] = true,
	["]"] = true,
	["}"] = true,
}

local quotes = {
	["'"] = "'",
	['"'] = '"',
	["`"] = "`",
}

local function close_it()
	local changeCol = currCol - prevCol
	local changeRow = currRow - prevRow
	-- 1 if single character inserted
	-- -1 if single character deleted
	if changeRow == 0 and changeCol == 1 then
		if lefts[currChar] and (posChar == " " or posChar == "" or rights[posChar] or quotes[posChar]) then
			-- [left] inserted, followed by [space|empty|rights|quotes] (close it)
			vim.api.nvim_buf_set_text(0, currRow - 1, currCol, currRow - 1, currCol, { lefts[currChar] })
		elseif rights[currChar] and posChar == currChar then
			-- [right] inserted, followed by [right] (skip it)
			vim.api.nvim_buf_set_text(0, currRow - 1, currCol, currRow - 1, currCol + 1, {})
		elseif
			quotes[currChar]
			and (prevChar == " " or prevChar == "" or lefts[prevChar] or quotes[prevChar])
			and (posChar == " " or posChar == "" or rights[posChar] or quotes[posChar])
		then
			-- [quote] inserted, followed by [space|empty|rights|quotes]
			local numBool = (posChar ~= quotes[currChar]) and 1 or 0
			-- 1 if followed by [space|empty|rights|otherquote] (close it)
			-- 0 if followed by [quote] (skip it)
			vim.api.nvim_buf_set_text(
				0,
				currRow - 1,
				currCol,
				currRow - 1,
				currCol + 1 - numBool,
				{ currChar:rep(numBool) }
			)
		end
	elseif changeRow == 0 and changeCol == -1 and (posChar == lefts[prevChar] or posChar == quotes[prevChar]) then
		-- [left/quote] deleted, followed by [right/quote] (delete it)
		vim.api.nvim_buf_set_text(0, currRow - 1, currCol, currRow - 1, currCol + 1, {})
	elseif changeRow == 1 and changeCol < 0 and posChar == lefts[prevChar] then
		-- enter is hit inside brackets
		local prevLine = vim.api.nvim_buf_get_lines(0, prevRow - 1, prevRow, false)[1]
		local indentation = prevLine:match("^%s*")
		vim.api.nvim_buf_set_text(0, currRow - 1, currCol, currRow - 1, currCol, { "", indentation })
		vim.api.nvim_input("<Tab>")
	end
end

local augroup = vim.api.nvim_create_augroup("CloseIt", { clear = true })

vim.api.nvim_create_autocmd({ "TextChangedI", "InsertEnter" }, {
	group = augroup,
	pattern = "*",
	callback = update_pos,
})
vim.api.nvim_create_autocmd({ "TextChangedI" }, {
	group = augroup,
	pattern = "*",
	callback = close_it,
})

-- Control + ` inserts a code block

local function code_fence()
	if currCol ~= 0 then
		return
	end
	vim.api.nvim_buf_set_text(0, currRow - 1, 0, currRow - 1, 0, { "```", "```" })
	vim.api.nvim_win_set_cursor(0, { currRow, 3 })
end

vim.keymap.set("i", "<C-`>", code_fence, { noremap = true })
