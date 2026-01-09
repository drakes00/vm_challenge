local lu = require("deps.luaunit")
local utils = require("modules.utils")

TestUtils = {}

function TestUtils:testRealAddr()
	lu.assertEquals(utils.realAddr(1), 0)
	lu.assertEquals(utils.realAddr(100), 99)
	lu.assertEquals(utils.realAddr(0x8000), 0x7fff)
end

function TestUtils:testLoadBinary()
	local filename = "test_utils_bin.bin"
	local f = io.open(filename, "wb")
	-- 0x0001 (01 00), 0x0203 (03 02), 0xFFFF (FF FF)
	f:write(string.char(0x01, 0x00, 0x03, 0x02, 0xff, 0xff))
	f:close()

	local mem = utils.loadBinary(filename)
	lu.assertEquals(#mem, 3)
	lu.assertEquals(mem[1], 0x0001)
	lu.assertEquals(mem[2], 0x0203)
	lu.assertEquals(mem[3], 0xffff)

	os.remove(filename)
end

function TestUtils:testLoadBinaryOddLength()
	local filename = "test_utils_odd.bin"
	local f = io.open(filename, "wb")
	-- 0x0001 (01 00), 0x0003 (03) -> trailing 0 assumed by code
	f:write(string.char(0x01, 0x00, 0x03))
	f:close()

	local mem = utils.loadBinary(filename)
	lu.assertEquals(#mem, 2)
	lu.assertEquals(mem[1], 0x0001)
	lu.assertEquals(mem[2], 0x0003)

	os.remove(filename)
end

function TestUtils:testDump()
	-- Mock print
	local output = {}
	local orig_print = print
	_G.print = function(s)
		table.insert(output, s)
	end

	local t = { [0x10] = 42 }
	utils.dump(t)

	_G.print = orig_print

	lu.assertEquals(#output, 1)
	lu.assertStrContains(output[1], "0x0010")
	lu.assertStrContains(output[1], "16")
	lu.assertStrContains(output[1], "42")
end

os.exit(lu.LuaUnit.run())
