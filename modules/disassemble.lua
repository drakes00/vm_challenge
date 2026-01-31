--- Helper function to format arguments.
-- Checks if the value is a register or a literal and formats accordingly.
-- @param mmu table The MMU.
-- @param val table The value to format.
-- @return string The formatted string.
local function format_arg(mmu, val)
	if val.addr >= 0x8000 then
		return string.format("R%x", val.addr - 0x8000)
	else
		return string.format("#%x", val.value)
	end
end

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
	print(string.format("%04x: SET %s %s", mmu.registers.pc - 4, format_arg(mmu, reg), format_arg(mmu, val)))
end

--- Push (2).
-- Disassembles the PUSH instruction.
-- @param mmu table The MMU, containing the PC.
-- @param reg table The value to push.
local function h2_push(mmu, reg)
	print(string.format("%04x: PUSH %s", mmu.registers.pc - 3, format_arg(mmu, reg)))
end

--- Pop (3).
-- Disassembles the POP instruction.
-- @param mmu table The MMU, containing the PC.
-- @param reg table The register to store the popped value in.
local function h3_pop(mmu, reg)
	print(string.format("%04x: POP %s", mmu.registers.pc - 3, format_arg(mmu, reg)))
end

--- Equality (4).
-- Disassembles the EQ instruction.
-- @param mmu table The MMU, containing the PC.
-- @param a table The destination register.
-- @param b table The first operand.
-- @param c table The second operand.
local function h4_eq(mmu, a, b, c)
	print(string.format("%04x: EQ %s, %s, %s", mmu.registers.pc - 5, format_arg(mmu, a), format_arg(mmu, b), format_arg(mmu, c)))
end

--- Greater Than (5).
-- Disassembles the GT instruction.
-- @param mmu table The MMU, containing the PC.
-- @param a table The destination register.
-- @param b table The first operand.
-- @param c table The second operand.
local function h5_gt(mmu, a, b, c)
	print(string.format("%04x: GT %s, %s, %s", mmu.registers.pc - 5, format_arg(mmu, a), format_arg(mmu, b), format_arg(mmu, c)))
end

--- Jump (6).
-- Disassembles the JMP instruction.
-- @param mmu table The MMU, containing the PC.
-- @param addr table The target address.
local function h6_jmp(mmu, addr)
	print(string.format("%04x: JMP %s", mmu.registers.pc - 3, format_arg(mmu, addr)))
end

--- Jump-if-true (7).
-- Disassembles the JT instruction.
-- @param mmu table The MMU, containing the PC.
-- @param test table The value to test.
-- @param addr table The target address.
local function h7_jt(mmu, test, addr)
	print(string.format("%04x: JT %s %s", mmu.registers.pc - 4, format_arg(mmu, test), format_arg(mmu, addr)))
end

--- Jump-if-false (8).
-- Disassembles the JF instruction.
-- @param mmu table The MMU, containing the PC.
-- @param test table The value to test.
-- @param addr table The target address.
local function h8_jf(mmu, test, addr)
	print(string.format("%04x: JF %s %s", mmu.registers.pc - 4, format_arg(mmu, test), format_arg(mmu, addr)))
end

--- Addition (9).
-- Disassembles the ADD instruction.
-- @param mmu table The MMU, containing the PC.
-- @param a table The destination register.
-- @param b table The first operand.
-- @param c table The second operand.
local function h9_add(mmu, a, b, c)
	print(string.format("%04x: ADD %s, %s, %s", mmu.registers.pc - 5, format_arg(mmu, a), format_arg(mmu, b), format_arg(mmu, c)))
end

--- Multiplication (10).
-- Disassembles the MULT instruction.
-- @param mmu table The MMU, containing the PC.
-- @param a table The destination register.
-- @param b table The first operand.
-- @param c table The second operand.
local function h10_mult(mmu, a, b, c)
	print(string.format("%04x: MULT %s, %s, %s", mmu.registers.pc - 5, format_arg(mmu, a), format_arg(mmu, b), format_arg(mmu, c)))
end

--- Modulo (11).
-- Disassembles the MOD instruction.
-- @param mmu table The MMU, containing the PC.
-- @param a table The destination register.
-- @param b table The first operand.
-- @param c table The second operand.
local function h11_mod(mmu, a, b, c)
	print(string.format("%04x: MOD %s, %s, %s", mmu.registers.pc - 5, format_arg(mmu, a), format_arg(mmu, b), format_arg(mmu, c)))
end

--- Logical And (12).
-- Disassembles the AND instruction.
-- @param mmu table The MMU, containing the PC.
-- @param a table The destination register.
-- @param b table The first operand.
-- @param c table The second operand.
local function h12_and(mmu, a, b, c)
	print(string.format("%04x: AND %s, %s, %s", mmu.registers.pc - 5, format_arg(mmu, a), format_arg(mmu, b), format_arg(mmu, c)))
end

--- Logical Or (13).
-- Disassembles the OR instruction.
-- @param mmu table The MMU, containing the PC.
-- @param a table The destination register.
-- @param b table The first operand.
-- @param c table The second operand.
local function h13_or(mmu, a, b, c)
	print(string.format("%04x: OR %s, %s, %s", mmu.registers.pc - 5, format_arg(mmu, a), format_arg(mmu, b), format_arg(mmu, c)))
end

--- Logical Not (14).
-- Disassembles the NOT instruction.
-- @param mmu table The MMU, containing the PC.
-- @param a table The destination register.
-- @param b table The first operand.
local function h14_not(mmu, a, b)
	print(string.format("%04x: NOT %s, %s", mmu.registers.pc - 4, format_arg(mmu, a), format_arg(mmu, b)))
end

--- Read Memory (15).
-- Disassembles the RMEM instruction.
-- @param mmu table The MMU, containing the PC.
-- @param a table The destination register.
-- @param addr table The address to read from.
local function h15_rmem(mmu, a, addr)
	print(string.format("%04x: RMEM %s, %s", mmu.registers.pc - 4, format_arg(mmu, a), format_arg(mmu, addr)))
end

--- Write Memory (16).
-- Disassembles the WMEM instruction.
-- @param mmu table The MMU, containing the PC.
-- @param addr table The address to write to.
-- @param b table The value to write.
local function h16_wmem(mmu, addr, b)
	print(string.format("%04x: WMEM %s, %s", mmu.registers.pc - 4, format_arg(mmu, addr), format_arg(mmu, b)))
end

--- Call instruction (17).
-- Disassembles the CALL instruction.
-- @param mmu table The MMU, containing the PC.
-- @param addr table The register containing the address to jump to.
local function h17_call(mmu, reg)
	print(string.format("%04x: CALL %s", mmu.registers.pc - 3, format_arg(mmu, reg)))
end

--- Return (18).
-- Disassembles the RET instruction.
-- @param mmu table The MMU, containing the PC.
local function h18_ret(mmu)
	print(string.format("%04x: RET", mmu.registers.pc - 2))
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

--- Input Character (20).
-- Disassembles the IN instruction.
-- @param mmu table The MMU, containing the PC.
-- @param a table The register to store the input character in.
local function h20_in(mmu, a)
	print(string.format("%04x: IN %x", mmu.registers.pc - 3, a.value))
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
	[10] = { handler = h10_mult, nargs = 3 },
	[11] = { handler = h11_mod, nargs = 3 },
	[12] = { handler = h12_and, nargs = 3 },
	[13] = { handler = h13_or, nargs = 3 },
	[14] = { handler = h14_not, nargs = 2 },
	[15] = { handler = h15_rmem, nargs = 2 },
	[16] = { handler = h16_wmem, nargs = 2 },
	[17] = { handler = h17_call, nargs = 1 },
	[18] = { handler = h18_ret, nargs = 0 },
	[19] = { handler = h19_out, nargs = 1 },
	[20] = { handler = h20_in, nargs = 1 },
	[21] = { handler = h21_nop, nargs = 0 },
}

return {
	opcodes = opcodes,
}
