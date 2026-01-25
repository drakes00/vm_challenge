local lu = require("deps.luaunit")
local vm = require("runit")
local mmu = require("modules.mmu")

TestRunit = {}

function TestRunit:setUp()
	mmu.code = { 1, 2, 3 } -- Dummy code
	mmu.registers.pc = 1
	mmu.registers.reg = {
		{ value = 0 },
		{ value = 0 },
		{ value = 0 },
		{ value = 0 },
		{ value = 0 },
		{ value = 0 },
		{ value = 0 },
		{ value = 0 },
	}
	vm.opcodes = {
		[1] = { handler = function() end, nargs = 2 },
	}
end

function TestRunit:testNext()
	mmu.registers.pc = 1
	vm.next()
	lu.assertEquals(mmu.registers.pc, 2)
end

function TestRunit:testFetch()
	mmu.registers.pc = 1
	local handler, nargs = vm.fetch()
	lu.assertIsFunction(handler)
	lu.assertEquals(nargs, 2)
end

function TestRunit:testFetchIllegal()
	mmu.registers.pc = 2 -- opcode 2 is not in vm.opcodes
	local handler, nargs = vm.fetch()
	lu.assertIsNil(handler)
	lu.assertIsNil(nargs)
end

function TestRunit:testLoadArgsWithHoles()
	-- Mock mmu.loadArg to return nil for the first call and a value for the second
	local call_count = 0
	local orig_loadArg = mmu.loadArg
	mmu.loadArg = function()
		call_count = call_count + 1
		if call_count == 1 then
			return nil
		else
			return { value = 42 }
		end
	end

	mmu.registers.pc = 1
	local args = vm.loadArgs(2)

	-- Restore mock
	mmu.loadArg = orig_loadArg

	-- Verify args individually, as #args is unreliable with holes
	lu.assertEquals(args[1], mmu)
	lu.assertIsNil(args[2])
	lu.assertIsTable(args[3])
	lu.assertEquals(args[3].value, 42)
	lu.assertEquals(mmu.registers.pc, 3)
end

function TestRunit:testStep()
	local captured_args = {}
	local mock_handler = function(...)
		captured_args = { ... }
	end

	-- Setup a dummy opcode (1) that uses the mock handler
	vm.opcodes = {
		[1] = { handler = mock_handler, nargs = 2 },
	}

	-- Mock mmu.loadArg to return predictable values
	local loadArgVals = { { value = 10 }, { value = 20 } }
	local orig_loadArg = mmu.loadArg
	local loadArgIdx = 0
	mmu.loadArg = function()
		loadArgIdx = loadArgIdx + 1
		return loadArgVals[loadArgIdx]
	end

	mmu.code = { 1, 0, 0 } -- Opcode 1, followed by dummy args
	mmu.registers.pc = 1

	vm.step()

	-- Restore mock
	mmu.loadArg = orig_loadArg

	lu.assertEquals(#captured_args, 3)
	lu.assertEquals(captured_args[1], mmu)
	lu.assertEquals(captured_args[2].value, 10)
	lu.assertEquals(captured_args[3].value, 20)
	lu.assertEquals(mmu.registers.pc, 4)
end

os.exit(lu.LuaUnit.run())

