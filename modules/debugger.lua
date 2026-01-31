local handlers = require("modules.handlers")
local mmu = require("modules.mmu")
local utils = require("modules.utils")
local disassemble = require("modules.disassemble")

local debugger = {}
local last_command = "step"

--- Pending operation handler (executed at the start of the next step).
debugger.handler = nil
--- Disassembly handler for the current instruction (executed immediately).
debugger.disasHandler = nil
--- Number of arguments for the current instruction.
debugger.nargs = nil
--- Argument list for the current instruction.
debugger.args = nil
--- Tracks the PC of the currently displayed instruction (not the fetch pointer).
debugger.pc = nil

-- Breakpoints handling.
debugger.breakpoints = {}

--- Sets a breakpoint at the specified address.
-- Adjusts for Lua's 1-based indexing vs the VM's 0-based addressing.
-- @param addr number|string The 0-based memory address to break at.
function debugger.setBreakPoint(addr)
	-- addr is the user-facing 0-based address.
	-- Lua tables are 1-based, so we store it at addr + 1.
	debugger.breakpoints[tonumber(addr) + 1] = true
	print(string.format("Breakpoint set at 0x%04x", tonumber(addr)))
end

--- Resumes execution until a breakpoint is hit or the program ends.
-- Iterates through steps, checking the traversed memory range for active breakpoints.
function debugger.continue()
	while true do
		local start_pc, end_pc = debugger.step()

		-- Check if we swept over any breakpoints during the fetch.
		-- We check from start_pc to end_pc - 1.
		for addr = start_pc, end_pc - 1 do
			if debugger.breakpoints[addr] then
				return
			end
		end

		-- Safety break if we run off the end of memory
		if mmu.registers.pc > #mmu.code then
			return
		end
	end
end

--- Fetches the instruction at the current PC.
-- Retrieves the execution handler and disassembly handler for the opcode.
-- If the opcode is unknown, it prints an error format and returns nil.
-- @return function|nil The opcode execution handler.
-- @return function|nil The opcode disassembly handler.
-- @return number|nil The number of arguments expected.
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

--- Advances the Program Counter (PC) by 1.
function debugger.next()
	mmu.registers.pc = mmu.registers.pc + 1
end

--- Loads arguments for the current instruction.
-- Reads 'nargs' values from memory starting at the current PC.
-- Advances the PC for each argument read.
-- @param nargs number The number of arguments to read.
-- @return table A list of arguments (starting with the MMU).
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

--- Executes a specific instruction handler.
-- @param handler function The handler function to call.
-- @param args table The list of arguments (mmu + operands).
-- @param nargs number The number of operands (used for unpacking).
function debugger.execute(handler, args, nargs)
	handler(table.unpack(args, 1, nargs + 1))
end

--- Performs a single debugger cycle (The Pipeline Step).
-- 1. Executes the *pending* instruction (logic determined in the previous step).
-- 2. Fetches the *next* instruction.
-- 3. Disassembles (prints) the *next* instruction immediately.
-- 4. Stores the *next* instruction logic as *pending* for the future.
-- @return number The PC at the start of the fetch (displayed instruction).
-- @return number The PC at the end of the fetch (next instruction start).
function debugger.step()
	-- 1. Execute the previously fetched instruction (Pipeline Execute)
	if debugger.handler ~= nil then
		debugger.execute(debugger.handler, debugger.args, debugger.nargs)
	end

	-- 2. Capture the start of the NEW instruction
	local start_pc = mmu.registers.pc
	debugger.pc = start_pc -- Update the debugger's view of "Current PC"

	-- 3. Fetch and Disassemble
	debugger.handler, debugger.disasHandler, debugger.nargs = debugger.fetch()
	debugger.next()

	debugger.args = {}
	if debugger.nargs ~= nil then
		debugger.args = debugger.loadArgs(debugger.nargs)
		-- Execute disassembly immediately so the user sees "Next Instruction"
		debugger.execute(debugger.disasHandler, debugger.args, debugger.nargs)
	end

	-- 4. Capture where we ended up (for range checking)
	local end_pc = mmu.registers.pc

	return start_pc, end_pc
end

--- Runs the debugger REPL (Read-Eval-Print Loop).
-- Handles user input for stepping, continuing, setting breakpoints, and inspecting state.
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
		elseif cmd == "b" or cmd == "break" or cmd == "bp" then
			if arg then
				debugger.setBreakPoint(arg)
			else
				print("Usage: b <address>")
			end
		elseif cmd == "c" or cmd == "cont" or cmd == "continue" then
			debugger.continue()
		elseif cmd == "r" or cmd == "regs" then
			-- Dump registers
			-- We use debugger.pc to show the address of the currently displayed instruction
			print(string.format("PC: %d (0x%04x)", utils.realAddr(debugger.pc), utils.realAddr(debugger.pc)))
			for i, reg in ipairs(mmu.registers.reg) do
				print(string.format("R%d: %d", i - 1, reg.value))
			end
		end
	end
end

return debugger

