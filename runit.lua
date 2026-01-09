#!/usr/bin/lua

-- runit.lua
-- Author: Maxime PUYS
-- Created: 2026-01-08
--
-- Description: Interpreter for Synacor Challenge

local handlers = require("modules.handlers")
local utils = require("modules.utils")

-- First load the binary.
local code = utils.loadBinary()

-- This will later contain all 8 registers.
local registers = {
	pc = 1,
}

--- Advances the Program Counter (PC).
-- Increments the pc register by 1 to point to the next instruction or argument.
local function next()
	registers.pc = registers.pc + 1
end

--- Fetches the current instruction.
-- Retrieves the opcode at the current PC location and looks up its handler.
-- @error Throws an error if the opcode is unknown.
-- @return function The handler function for the opcode.
-- @return number The number of arguments the opcode expects.
local function fetch()
	local opcode = code[registers.pc]
	local opcodeInfo = handlers.opcodes[opcode]
	if opcodeInfo == nil then
		error(string.format("[Illegal instruction] 0x%08x: 0x%02x (%d)", utils.realAddr(registers.pc), opcode, opcode))
	else
		-- print(string.format("[DBG] 0x%08x: 0x%02x (%d)", utils.realAddr(registers.pc), opcode, opcode))
		return opcodeInfo.handler, opcodeInfo.nargs
	end
end

--- Loads arguments for the current instruction.
-- Reads 'nargs' values from memory starting at the current PC.
-- Advances the PC for each argument read.
-- @param nargs number The number of arguments to read.
-- @return table A list of arguments.
local function loadArgs(nargs)
	local args = { registers }
	while nargs > 0 do
		table.insert(args, code[registers.pc])
		next()
		nargs = nargs - 1
	end

	return args
end

-- Main fetch and execute loop.
while registers.pc <= #code do
	local handler, nargs = fetch()
	next()

	local args = loadArgs(nargs)
	handler(table.unpack(args))
end
