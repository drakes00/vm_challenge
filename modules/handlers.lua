--- Halt (0).
-- Stop execution and terminate the program.
-- @param _ table Unused registers table.
local function h0_halt(_)
	os.exit(1)
end

local function h1_set(_, reg, val)
	reg.value = val.value
end

--- Equality (4).
-- Sets register <a> to 1 if <b> is equal to <c>; set it to 0 otherwise.
-- @param _ table Unused registers table.
-- @param a table The register to store the result in.
-- @param b table The first value to compare.
-- @param c table The second value to compare.
local function h4_eq(_, a, b, c)
	if b.value == c.value then
		a.value = 1
	else
		a.value = 0
	end
end

--- Jump (6).
-- Unconditionally jump to the specified address.
-- Updates the program counter (PC) to the target address.
-- @param registers table The VM registers, containing the PC.
-- @param addr number The absolute address to jump to.
local function h6_jmp(registers, addr)
	-- local utils = require("modules.utils")
	-- print(string.format("[DBG] 0x%08x: JMP (0x%04x)", utils.realAddr(registers.pc - 2), addr()))
	registers.pc = addr.value + 1
end

--- Jump-if-true (7).
-- If <a> is nonzero, jump to <b>.
-- @param registers table The VM registers, containing the PC.
-- @param test number The value to test for non-zero.
-- @param addr number The address to jump to if the test passes.
local function h7_jt(registers, test, addr)
	-- local utils = require("modules.utils")
	-- print(string.format("[DBG] 0x%08x: JT (%d, 0x%04x)", utils.realAddr(registers.pc - 3), test.value, addr.value))
	if test.value ~= 0 then
		registers.pc = addr.value + 1
	end
end

--- Jump-if-false (8).
-- If <a> is zero, jump to <b>.
-- @param registers table The VM registers, containing the PC.
-- @param test number The value to test for zero.
-- @param addr number The address to jump to if the test passes.
local function h8_jf(registers, test, addr)
	-- local utils = require("modules.utils")
	-- print(string.format("[DBG] 0x%08x: JF (%d, 0x%04x)", utils.realAddr(registers.pc - 3), test.value, addr.value))
	if test.value == 0 then
		registers.pc = addr.value + 1
	end
end

--- Addition (9).
-- Assign into <a> the sum of <b> and <c> (modulo 32768).
-- @param _ table Unused registers table.
-- @param a table The register to store the result in.
-- @param b table The first operand.
-- @param c table The second operand.
local function h9_add(_, a, b, c)
	a.value = (b.value + c.value) % 0x8000
end

--- Output Character (19).
-- Writes a single character to the standard output.
-- @param _ table Unused registers table.
-- @param char number The ASCII code of the character to print.
local function h19_out(_, char)
	io.write(string.char(char.value))
end

--- No Operation (21).
-- This handler performs no action and acts as a placeholder or delay.
local function h21_nop(_) end

-- This will later contain all handlers for opcodes.
local opcodes = {
	[0] = { handler = h0_halt, nargs = 0 },
	[1] = { handler = h1_set, nargs = 2 },
	[4] = { handler = h4_eq, nargs = 3 },
	[6] = { handler = h6_jmp, nargs = 1 },
	[7] = { handler = h7_jt, nargs = 2 },
	[8] = { handler = h8_jf, nargs = 2 },
	[9] = { handler = h9_add, nargs = 3 },
	[19] = { handler = h19_out, nargs = 1 },
	[21] = { handler = h21_nop, nargs = 0 },
}

return {
	opcodes = opcodes,
}
