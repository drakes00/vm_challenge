local lu = require("deps.luaunit")
local mmu = require("modules.mmu")

TestMMU = {}

function TestMMU:setUp()
	-- Reset state before each test
	mmu.code = {}
	mmu.registers.pc = 1
	mmu.registers.reg = { 0, 0, 0, 0, 0, 0, 0, 0 }
end

function TestMMU:testMapAddressLiteral()
	lu.assertEquals(mmu.mapAddress(0), 0)
	lu.assertEquals(mmu.mapAddress(12345), 12345)
	lu.assertEquals(mmu.mapAddress(32767), 32767)
end

function TestMMU:testMapAddressRegister()
	-- Set register values
	mmu.registers.reg[1] = 42 -- Register 0 (32768 maps to index 1)
	mmu.registers.reg[8] = 99 -- Register 7 (32775 maps to index 8)

	lu.assertEquals(mmu.mapAddress(32768), 42)
	lu.assertEquals(mmu.mapAddress(32775), 99)
end

function TestMMU:testMapAddressInvalid()
	lu.assertErrorMsgContains("[Segmentation Fault]", mmu.mapAddress, 32776)
end

function TestMMU:testLoadArg()
	mmu.code = { 10, 32768 } -- 10 (literal), 32768 (Register 0)
	mmu.registers.reg[1] = 55
	mmu.registers.pc = 1

	-- Load first arg (literal 10)
	lu.assertEquals(mmu.loadArg(), 10)

	-- Advance PC (simulation)
	mmu.registers.pc = 2

	-- Load second arg (Register 0 -> 55)
	lu.assertEquals(mmu.loadArg(), 55)
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
