local vim = vim
local curr = vim.api.nvim_win_get_cursor(0)
local prev
local currChar = "" -- character right before cursor (current)
local prevChar -- character right before cursor (previous)
local posChar = "" -- character right after cursor (current)

local function update_pos()
	-- get_cursor: top right corner is (1, 0)
	prev = curr
	curr = vim.api.nvim_win_get_cursor(0)
	prevChar = currChar
	if curr[2] == 0 then
		currChar = ""
	else
		currChar = vim.api.nvim_buf_get_text(0, curr[1] - 1, curr[2] - 1, curr[1] - 1, curr[2], {})[1]
	end
	posChar = vim.api.nvim_buf_get_text(0, curr[1] - 1, curr[2], curr[1] - 1, curr[2] + 1, {})[1]
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
	local changeCol = curr[2] - prev[2]
	local changeRow = curr[1] - prev[1]
	-- 1 if single character inserted
	-- -1 if single character deleted
	if changeRow == 0 and changeCol == 1 then
		if lefts[currChar] and (posChar == " " or posChar == "" or rights[posChar] or quotes[posChar]) then
			-- [left] inserted, followed by [space|empty|rights|quotes] (close it)
			vim.api.nvim_buf_set_text(0, curr[1] - 1, curr[2], curr[1] - 1, curr[2], { lefts[currChar] })
		elseif rights[currChar] and posChar == currChar then
			-- [right] inserted, followed by [right] (skip it)
			vim.api.nvim_buf_set_text(0, curr[1] - 1, curr[2], curr[1] - 1, curr[2] + 1, {})
		elseif quotes[currChar] and (posChar == " " or posChar == "" or rights[posChar] or quotes[posChar]) then
			-- [quote] inserted, followed by [space|empty|rights|quotes]
			local numBool = (posChar ~= quotes[currChar]) and 1 or 0
			-- 1 if followed by [space|empty|rights|otherquote] (close it)
			-- 0 if followed by [quote] (skip it)
			vim.api.nvim_buf_set_text(
				0,
				curr[1] - 1,
				curr[2],
				curr[1] - 1,
				curr[2] + 1 - numBool,
				{ currChar:rep(numBool) }
			)
		end
	elseif changeRow == 0 and changeCol == -1 and (posChar == lefts[prevChar] or posChar == quotes[prevChar]) then
		-- [left/quote] deleted, followed by [right/quote] (delete it)
		vim.api.nvim_buf_set_text(0, curr[1] - 1, curr[2], curr[1] - 1, curr[2] + 1, {})
	elseif changeRow == 1 and changeCol < 0 and posChar == lefts[prevChar] then
		-- enter is hit inside brackets
		local prevLine = vim.api.nvim_buf_get_lines(0, prev[1] - 1, prev[1], false)[1]
		local indentation = prevLine:match("^%s*")
		vim.api.nvim_buf_set_text(0, curr[1] - 1, curr[2], curr[1] - 1, curr[2], { "", indentation })
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
	if curr[2] ~= 0 then
		return
	end
	vim.api.nvim_buf_set_text(0, curr[1] - 1, 0, curr[1] - 1, 0, { "```", "```" })
	vim.api.nvim_win_set_cursor(0, { curr[1], 3 })
end

vim.keymap.set("i", "<C-`>", code_fence, { noremap = true })
