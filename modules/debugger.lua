local handlers = require("modules.handlers")
local mmu = require("modules.mmu")
local utils = require("modules.utils")
local disassemble = require("modules.disassemble")

local debugger = {}
local last_command = "step"

debugger.handler = nil
debugger.disasHandler = nil
debugger.nargs = nil
debugger.args = nil

function debugger.fetch()
	local opcode = mmu.code[mmu.registers.pc]
	local opcodeInfo = handlers.opcodes[opcode]
	local disasInfo = disassemble.opcodes[opcode]
	if opcodeInfo ~= nil and disasInfo ~= nil then
		assert(opcodeInfo.nargs == disasInfo.nargs)
		return opcodeInfo.handler, disasInfo.handler, opcodeInfo.nargs
	else
		print(string.format("%04x: #0x%02x (%d)", utils.realAddr(mmu.registers.pc), opcode, opcode))
	end
end

function debugger.next()
	mmu.registers.pc = mmu.registers.pc + 1
end

--- Loads arguments for the current instruction.
-- Reads 'nargs' values from memory starting at the current PC.
-- Advances the PC for each argument read.
-- @param nargs number The number of arguments to read.
-- @return table A list of arguments.
function debugger.loadArgs(nargs)
	local args = { mmu }
	local idx = 2
	for _ = 1, nargs do
		args[idx] = mmu.loadArg()
		debugger.next()
		idx = idx + 1
	end
	return args
end

function debugger.execute(handler, args, nargs)
	handler(table.unpack(args, 1, nargs + 1))
end

function debugger.step()
	if debugger.handler ~= nil then
		debugger.execute(debugger.handler, debugger.args, debugger.nargs)
	end

	debugger.handler, debugger.disasHandler, debugger.nargs = debugger.fetch()
	debugger.next()

	debugger.args = {}
	if debugger.nargs ~= nil then
		debugger.args = debugger.loadArgs(debugger.nargs)
		debugger.execute(debugger.disasHandler, debugger.args, debugger.nargs)
	end
end

function debugger.run()
	debugger.step()
	while mmu.registers.pc <= #mmu.code do
		io.write("(dbg)> ")
		local line = io.read() or "quit"
		if line == "" then
			line = last_command
		end
		last_command = line
		local cmd, arg = line:match("^(%S+)%s*(.*)$")

		if cmd == "q" or cmd == "quit" then
			os.exit(0)
		elseif cmd == "s" or cmd == "step" or cmd == "n" or cmd == "next" then
			debugger.step()
		end
	end
end

return debugger
