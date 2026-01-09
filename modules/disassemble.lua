--- Halt (0).
-- Disassembles the HALT instruction.
-- @param registers table The VM registers, containing the PC.
local function h0_halt(registers)
	print(string.format("%04x: HALT", registers.pc - 2))
end

--- Set Register (1).
-- Disassembles the SET instruction.
-- @param registers table The VM registers, containing the PC.
-- @param reg number The register to set.
-- @param val number The value to set the register to.
local function h1_set(registers, reg, val)
	print(string.format("%04x: SET %x 0x%04x", registers.pc - 4, reg, val))
end

--- Jump (6).
-- Disassembles the JMP instruction.
-- @param registers table The VM registers, containing the PC.
-- @param addr number The target address.
local function h6_jmp(registers, addr)
	print(string.format("%04x: JMP 0x%04x", registers.pc - 3, addr))
end

--- Jump-if-true (7).
-- Disassembles the JT instruction.
-- @param registers table The VM registers, containing the PC.
-- @param test number The value to test.
-- @param addr number The target address.
local function h7_jt(registers, test, addr)
	print(string.format("%04x: JT %x 0x%04x", registers.pc - 4, test, addr))
end

--- Jump-if-false (8).
-- Disassembles the JF instruction.
-- @param registers table The VM registers, containing the PC.
-- @param test number The value to test.
-- @param addr number The target address.
local function h8_jf(registers, test, addr)
	print(string.format("%04x: JF %x 0x%04x", registers.pc - 4, test, addr))
end

--- Output Character (19).
-- Disassembles the OUT instruction.
-- @param registers table The VM registers, containing the PC.
-- @param char number The character code to print.
local function h19_out(registers, char)
	if char == 10 then
		char = 95
	end
	print(string.format("%04x: OUT %c", registers.pc - 3, char))
end

--- No Operation (21).
-- Disassembles the NOP instruction.
-- @param registers table The VM registers, containing the PC.
local function h21_nop(registers)
	print(string.format("%04x: NOP", registers.pc - 2))
end

-- This will later contain all handlers for opcodes.
local opcodes = {
	[0] = { handler = h0_halt, nargs = 0 },
	[1] = { handler = h1_set, nargs = 2 },
	[6] = { handler = h6_jmp, nargs = 1 },
	[7] = { handler = h7_jt, nargs = 2 },
	[8] = { handler = h8_jf, nargs = 2 },
	[19] = { handler = h19_out, nargs = 1 },
	[21] = { handler = h21_nop, nargs = 0 },
}

return {
	opcodes = opcodes,
}
