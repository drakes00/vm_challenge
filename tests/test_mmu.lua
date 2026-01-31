local lu = require("deps.luaunit")
local mmu = require("modules.mmu")

TestMMU = {}

function TestMMU:setUp()
	-- Reset state before each test
	mmu.code = {}
	mmu.registers.pc = 1
	mmu.registers.reg = {
		{ addr = 0x8000, value = 0 },
		{ addr = 0x8001, value = 0 },
		{ addr = 0x8002, value = 0 },
		{ addr = 0x8003, value = 0 },
		{ addr = 0x8004, value = 0 },
		{ addr = 0x8005, value = 0 },
		{ addr = 0x8006, value = 0 },
		{ addr = 0x8007, value = 0 },
	}
end

function TestMMU:testMapAddressLiteral()
	local res = mmu.mapAddress(0)
	lu.assertIsTable(res)
	lu.assertEquals(res.value, 0)

	res = mmu.mapAddress(12345)
	lu.assertIsTable(res)
	lu.assertEquals(res.value, 12345)

	res = mmu.mapAddress(32767)
	lu.assertIsTable(res)
	lu.assertEquals(res.value, 32767)
end

function TestMMU:testMapAddressRegister()
	-- Set register values
	mmu.registers.reg[1].value = 42 -- Register 0 (32768 maps to index 1)
	mmu.registers.reg[8].value = 99 -- Register 7 (32775 maps to index 8)

	local res = mmu.mapAddress(32768)
	lu.assertIsTable(res)
	lu.assertEquals(res.value, 42)
	-- Verify it returns the actual register table
	lu.assertTrue(res == mmu.registers.reg[1])

	res = mmu.mapAddress(32775)
	lu.assertIsTable(res)
	lu.assertEquals(res.value, 99)
	lu.assertTrue(res == mmu.registers.reg[8])
end

function TestMMU:testMapAddressInvalid()
	lu.assertErrorMsgContains("[Segmentation Fault]", mmu.mapAddress, 32776)
end

function TestMMU:testLoadArg()
	mmu.code = { 10, 32768 } -- 10 (literal), 32768 (Register 0)
	mmu.registers.reg[1].value = 55
	mmu.registers.pc = 1

	-- Load first arg (literal 10)
	local arg1 = mmu.loadArg()
	lu.assertIsTable(arg1)
	lu.assertEquals(arg1.value, 10)

	-- Advance PC (simulation)
	mmu.registers.pc = 2

	-- Load second arg (Register 0 -> 55)
	local arg2 = mmu.loadArg()
	lu.assertIsTable(arg2)
	lu.assertEquals(arg2.value, 55)
	lu.assertTrue(arg2 == mmu.registers.reg[1])
end

function TestMMU:testInit()
	local filename = "test_bin.bin"
	local f = io.open(filename, "wb")
	-- write 2 16-bit integers: 0x0102, 0x0304. Little endian: 02 01 04 03
	f:write(string.char(0x02, 0x01, 0x04, 0x03))
	f:close()

	mmu.init(filename)

	lu.assertEquals(#mmu.code, 2)
	lu.assertEquals(mmu.code[1], 0x0102) -- 258
	lu.assertEquals(mmu.code[2], 0x0304) -- 772

	os.remove(filename)
end

os.exit(lu.LuaUnit.run())
