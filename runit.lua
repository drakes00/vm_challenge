#!/usr/bin/lua

-- runit.lua
-- Author: Maxime PUYS
-- Created: 2026-01-08
--
-- Description: Interpreter for Synacor Challenge

local handlers = require("modules.handlers")
local mmu = require("modules.mmu")
local utils = require("modules.utils")
local disassemble = require("modules.disassemble")

local VM = {}

-- This will store the opcode handlers.
VM.opcodes = nil

--- Advances the Program Counter (PC).
-- Increments the pc register by 1 to point to the next instruction or argument.
function VM.next()
	mmu.registers.pc = mmu.registers.pc + 1
end

--- Fetches the current instruction.
-- Retrieves the opcode at the current PC location and looks up its handler.
-- @error Throws an error if the opcode is unknown.
-- @return function The handler function for the opcode.
-- @return number The number of arguments the opcode expects.
function VM.fetch()
	assert(VM.opcodes)
	local opcode = mmu.code[mmu.registers.pc]
	local opcodeInfo = VM.opcodes[opcode]
	if opcodeInfo == nil then
		error(
			string.format("[Illegal instruction] 0x%08x: 0x%02x (%d)", utils.realAddr(mmu.registers.pc), opcode, opcode)
		)
	else
		return opcodeInfo.handler, opcodeInfo.nargs
	end
end

--- Loads arguments for the current instruction.
-- Reads 'nargs' values from memory starting at the current PC.
-- Advances the PC for each argument read.
-- @param nargs number The number of arguments to read.
-- @return table A list of arguments.
function VM.loadArgs(nargs)
	local args = { mmu.registers }
	local idx = 2
	for _ = 1, nargs do
		args[idx] = mmu.loadArg()
		VM.next()
		idx = idx + 1
	end
	return args
end

--- Executes a single instruction cycle.
-- Fetches the opcode, loads arguments, and calls the handler.
function VM.step()
	local handler, nargs = VM.fetch()
	VM.next()

	local args_vals = VM.loadArgs(nargs)
	-- Using explicit bounds for unpack to handle potential nil values correctly
	handler(table.unpack(args_vals, 1, nargs + 1))
end

--- Sets up the VM with the given binary and mode.
-- Initializes the MMU and selects the opcode set.
-- @param filename string The path to the binary file.
-- @param mode string "run" or "disassemble".
function VM.setup(filename, mode)
	mmu.init(filename)

	if mode == "disassemble" then
		VM.opcodes = disassemble.opcodes
	else
		VM.opcodes = handlers.opcodes
	end
end

--- Runs the VM execution loop.
-- Continues until the PC goes out of bounds or a HALT instruction stops it.
function VM.run()
	while mmu.registers.pc <= #mmu.code do
		VM.step()
	end
end

--- Main entry point.
-- Parses command line arguments and starts the VM or disassembler.
function VM.main(args)
	local filename
	local mode = "run"

	args = args or _G.arg

	for i = 1, #args do
		if args[i] == "-d" then
			mode = "disassemble"
		else
			filename = args[i]
		end
	end

	if not filename then
		print(string.format("Usage: %s <binary> [-d]", _G.arg[0]))
		os.exit(1)
	end

	VM.setup(filename, mode)
	VM.run()
end

-- If this script is executed directly
if not pcall(debug.getlocal, 4, 1) then
	VM.main()
end

return VM