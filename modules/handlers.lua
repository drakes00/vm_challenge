--- Halt (0).
-- Stop execution and terminate the program.
-- @param _ table Unused MMU table.
local function h0_halt(_)
	os.exit(1)
end

--- Set Register (1).
-- Sets register <a> to the value of <b>.
-- @param _ table Unused MMU table.
-- @param reg table The register to set.
-- @param val table The value to set the register to.
local function h1_set(_, reg, val)
	reg.value = val.value
end

--- Push (2).
-- Push the value of <a> onto the stack.
-- @param mmu table The MMU, containing the stack and registers.
-- @param reg table The value to push.
local function h2_push(mmu, reg)
	mmu.stack[mmu.registers.sp] = reg.value
	mmu.registers.sp = mmu.registers.sp + 1
end

--- Pop (3).
-- Remove the top element from the stack and write it into <a>.
-- @error Throws an error if the stack is empty.
-- @param mmu table The MMU, containing the stack and registers.
-- @param reg table The register to store the popped value in.
local function h3_pop(mmu, reg)
	if mmu.registers.sp <= 1 then
		error("[Stack Underflow] Cannot pop from empty stack")
	end
	mmu.registers.sp = mmu.registers.sp - 1
	reg.value = mmu.stack[mmu.registers.sp]
end

--- Equality (4).
-- Sets register <a> to 1 if <b> is equal to <c>; set it to 0 otherwise.
-- @param _ table Unused MMU table.
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

--- Greater Than (5).
-- Sets register <a> to 1 if <b> is greater than <c>; set it to 0 otherwise.
-- @param _ table Unused MMU table.
-- @param a table The register to store the result in.
-- @param b table The first value to compare.
-- @param c table The second value to compare.
local function h5_gt(_, a, b, c)
	if b.value > c.value then
		a.value = 1
	else
		a.value = 0
	end
end

--- Jump (6).
-- Unconditionally jump to the specified address.
-- Updates the program counter (PC) to the target address.
-- @param mmu table The MMU, containing the registers (PC).
-- @param addr table The absolute address to jump to.
local function h6_jmp(mmu, addr)
	mmu.registers.pc = addr.value + 1
end

--- Jump-if-true (7).
-- If <a> is nonzero, jump to <b>.
-- @param mmu table The MMU, containing the registers (PC).
-- @param test table The value to test for non-zero.
-- @param addr table The address to jump to if the test passes.
local function h7_jt(mmu, test, addr)
	if test.value ~= 0 then
		mmu.registers.pc = addr.value + 1
	end
end

--- Jump-if-false (8).
-- If <a> is zero, jump to <b>.
-- @param mmu table The MMU, containing the registers (PC).
-- @param test table The value to test for zero.
-- @param addr table The address to jump to if the test passes.
local function h8_jf(mmu, test, addr)
	if test.value == 0 then
		mmu.registers.pc = addr.value + 1
	end
end

--- Addition (9).
-- Assign into <a> the sum of <b> and <c> (modulo 32768).
-- @param _ table Unused MMU table.
-- @param a table The register to store the result in.
-- @param b table The first operand.
-- @param c table The second operand.
local function h9_add(_, a, b, c)
	a.value = (b.value + c.value) % 0x8000
end

--- Output Character (19).
-- Writes a single character to the standard output.
-- @param _ table Unused MMU table.
-- @param char table The ASCII code of the character to print.
local function h19_out(_, char)
	io.write(string.char(char.value))
end

--- No Operation (21).
-- This handler performs no action and acts as a placeholder or delay.
-- @param _ table Unused MMU table.
local function h21_nop(_) end

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
