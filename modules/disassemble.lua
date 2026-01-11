--- Halt (0).
-- Disassembles the HALT instruction.
-- @param mmu table The MMU, containing the PC.
local function h0_halt(mmu)
	print(string.format("%04x: HALT", mmu.registers.pc - 2))
end

--- Set Register (1).
-- Disassembles the SET instruction.
-- @param mmu table The MMU, containing the PC.
-- @param reg table The register to set.
-- @param val table The value to set the register to.
local function h1_set(mmu, reg, val)
	print(string.format("%04x: SET %x 0x%04x", mmu.registers.pc - 4, reg.value, val.value))
end

--- Push (2).
-- Disassembles the PUSH instruction.
-- @param mmu table The MMU, containing the PC.
-- @param reg table The value to push.
local function h2_push(mmu, reg)
	print(string.format("%04x: PUSH %x", mmu.registers.pc - 3, reg.value))
end

--- Pop (3).
-- Disassembles the POP instruction.
-- @param mmu table The MMU, containing the PC.
-- @param reg table The register to store the popped value in.
local function h3_pop(mmu, reg)
	print(string.format("%04x: POP %x", mmu.registers.pc - 3, reg.value))
end

--- Equality (4).
-- Disassembles the EQ instruction.
-- @param mmu table The MMU, containing the PC.
-- @param a table The destination register.
-- @param b table The first operand.
-- @param c table The second operand.
local function h4_eq(mmu, a, b, c)
	print(string.format("%04x: EQ %x, %x, %x", mmu.registers.pc - 5, a.value, b.value, c.value))
end

--- Greater Than (5).
-- Disassembles the GT instruction.
-- @param mmu table The MMU, containing the PC.
-- @param a table The destination register.
-- @param b table The first operand.
-- @param c table The second operand.
local function h5_gt(mmu, a, b, c)
	print(string.format("%04x: GT %x, %x, %x", mmu.registers.pc - 5, a.value, b.value, c.value))
end

--- Jump (6).
-- Disassembles the JMP instruction.
-- @param mmu table The MMU, containing the PC.
-- @param addr table The target address.
local function h6_jmp(mmu, addr)
	print(string.format("%04x: JMP 0x%04x", mmu.registers.pc - 3, addr.value))
end

--- Jump-if-true (7).
-- Disassembles the JT instruction.
-- @param mmu table The MMU, containing the PC.
-- @param test table The value to test.
-- @param addr table The target address.
local function h7_jt(mmu, test, addr)
	print(string.format("%04x: JT %x 0x%04x", mmu.registers.pc - 4, test.value, addr.value))
end

--- Jump-if-false (8).
-- Disassembles the JF instruction.
-- @param mmu table The MMU, containing the PC.
-- @param test table The value to test.
-- @param addr table The target address.
local function h8_jf(mmu, test, addr)
	print(string.format("%04x: JF %x 0x%04x", mmu.registers.pc - 4, test.value, addr.value))
end

--- Addition (9).
-- Disassembles the ADD instruction.
-- @param mmu table The MMU, containing the PC.
-- @param a table The destination register.
-- @param b table The first operand.
-- @param c table The second operand.
local function h9_add(mmu, a, b, c)
	print(string.format("%04x: ADD %x, %x, %x", mmu.registers.pc - 5, a.value, b.value, c.value))
end

--- Output Character (19).
-- Disassembles the OUT instruction.
-- @param mmu table The MMU, containing the PC.
-- @param char table The character code to print.
local function h19_out(mmu, char)
	local pchar
	if char.value == 10 then
		pchar = 95
	else
		pchar = char.value
	end
	print(string.format("%04x: OUT %c", mmu.registers.pc - 3, pchar))
end

--- No Operation (21).
-- Disassembles the NOP instruction.
-- @param mmu table The MMU, containing the PC.
local function h21_nop(mmu)
	print(string.format("%04x: NOP", mmu.registers.pc - 2))
end

-- This will later contain all handlers for opcodes.
local opcodes = {
	[0] = { handler = h0_halt, nargs = 0 },
	[1] = { handler = h1_set, nargs = 2 },
	[2] = { handler = h2_push, nargs = 1 },
	[3] = { handler = h3_pop, nargs = 1 },
	[4] = { handler = h4_eq, nargs = 3 },
	[5] = { handler = h5_gt, nargs = 3 },
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
