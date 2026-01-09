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

-- This will store the opcode handlers.
local opcodes = nil

--- Advances the Program Counter (PC).
-- Increments the pc register by 1 to point to the next instruction or argument.
local function next()
	mmu.registers.pc = mmu.registers.pc + 1
end

--- Fetches the current instruction.
-- Retrieves the opcode at the current PC location and looks up its handler.
-- @error Throws an error if the opcode is unknown.
-- @return function The handler function for the opcode.
-- @return number The number of arguments the opcode expects.
local function fetch()
	assert(opcodes)
	local opcode = mmu.code[mmu.registers.pc]
	local opcodeInfo = opcodes[opcode]
	if opcodeInfo == nil then
		error(
			string.format("[Illegal instruction] 0x%08x: 0x%02x (%d)", utils.realAddr(mmu.registers.pc), opcode, opcode)
		)
	else
		-- print(string.format("[DBG] 0x%08x: 0x%02x (%d)", utils.realAddr(mmu.registers.pc), opcode, opcode))
		return opcodeInfo.handler, opcodeInfo.nargs
	end
end

--- Loads arguments for the current instruction.
-- Reads 'nargs' values from memory starting at the current PC.
-- Advances the PC for each argument read.
-- @param nargs number The number of arguments to read.
-- @return table A list of arguments.
local function loadArgs(nargs)
	local args = { mmu.registers }
	while nargs > 0 do
		table.insert(args, mmu.loadArg())
		next()
		nargs = nargs - 1
	end

	return args
end

--- Main entry point.
-- Parses command line arguments and starts the VM or disassembler.
local function main()
	local filename
	local mode = "run"

	for i = 1, #arg do
		if arg[i] == "-d" then
			mode = "disassemble"
		else
			filename = arg[i]
		end
	end

	if not filename then
		print(string.format("Usage: %s <binary> [-d]", arg[0]))
		os.exit(1)
	end

	mmu.init(filename)

	if mode == "disassemble" then
		opcodes = disassemble.opcodes
	else
		opcodes = handlers.opcodes
	end

	-- Main fetch and execute loop.
	while mmu.registers.pc <= #mmu.code do
		local handler, nargs = fetch()
		next()

		local args = loadArgs(nargs)
		handler(table.unpack(args))
	end
end

main()
