local utils = require("modules.utils")

local mmu = {}

mmu.code = {}

-- This will later contain all 8 registers.
mmu.registers = {
	pc = 1,
	reg = { 0, 0, 0, 0, 0, 0, 0, 0 },
}

mmu.stack = {}

--- Initializes the MMU with the given binary file.
-- Loads the binary program into memory.
-- @param filename string The path to the binary file to load.
function mmu.init(filename)
	mmu.code = utils.loadBinary(filename)
end

--- Maps a virtual address to a value.
-- Handles the distinction between literal values (0..32767) and registers (32768..32775).
-- @param addr number The address or register identifier to map.
-- @return number The value at the address or the value contained in the register.
-- @error Throws a "Segmentation Fault" error if the address is out of bounds.
function mmu.mapAddress(addr)
	if addr < 0x8000 then
		return addr
	elseif addr < 0x8008 then
		addr = addr % 0x8000
		return mmu.registers.reg[addr + 1]
	else
		error(string.format("[Segmentation Fault] 0x%08x", addr))
	end
end

--- Loads the next argument from memory.
-- Reads the value at the current PC, maps it (literal or register), and returns the result.
-- Note: This function relies on the caller to advance the PC (usually via `next()`).
-- @return number The resolved value of the argument at the current PC.
function mmu.loadArg()
	return mmu.mapAddress(mmu.code[mmu.registers.pc])
end

return mmu

