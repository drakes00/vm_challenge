--- Halt (0).
-- Stop execution and terminate the program.
-- @param _ table Unused registers table.
local function h0_halt(_)
	os.exit(1)
end

--- Jump (6).
-- Unconditionally jump to the specified address.
-- Updates the program counter (PC) to the target address.
-- @param registers table The VM registers, containing the PC.
-- @param addr number The absolute address to jump to.
local function h6_jump(registers, addr)
	local utils = require("modules.utils")
	-- print(string.format("[DBG] 0x%08x: JMP (0x%04x)", utils.realAddr(registers.pc - 2), addr + 1))
	registers.pc = addr + 1
end

--- Output Character (19).
-- Writes a single character to the standard output.
-- @param char number The ASCII code of the character to print.
local function h19_out(_, char)
	io.write(string.char(char))
end

--- No Operation (21).
-- This handler performs no action and acts as a placeholder or delay.
local function h21_nop(_) end

-- This will later contain all handlers for opcodes.
local opcodes = {
	[0] = { handler = h0_halt, nargs = 0 },
	[6] = { handler = h6_jump, nargs = 1 },
	[19] = { handler = h19_out, nargs = 1 },
	[21] = { handler = h21_nop, nargs = 0 },
}

return {
	opcodes = opcodes,
}
