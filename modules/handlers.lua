--- No Operation (21).
-- This handler performs no action and acts as a placeholder or delay.
local function h21_nop() end

--- Output Character (19).
-- Writes a single character to the standard output.
-- @param char number The ASCII code of the character to print.
local function h19_out(char)
	io.write(string.char(char))
end

-- This will later contain all handlers for opcodes.
local opcodes = {
	[19] = { handler = h19_out, nargs = 1 },
	[21] = { handler = h21_nop, nargs = 0 },
}

return {
	opcodes = opcodes,
}
