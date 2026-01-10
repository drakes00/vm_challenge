local lu = require("deps.luaunit")
local handlers = require("modules.handlers")

TestHandlers = {}

function TestHandlers:setUp()
	self.registers = {
		pc = 100,
		reg = {
			{ value = 0 },
			{ value = 0 },
			{ value = 0 },
			{ value = 0 },
			{ value = 0 },
			{ value = 0 },
			{ value = 0 },
			{ value = 0 },
		},
	}

	-- Mock os.exit
	self.orig_exit = os.exit
	self.exit_code = nil
	os.exit = function(code)
		self.exit_code = code
	end

	-- Mock io.write
	self.orig_write = io.write
	self.stdout = ""
	io.write = function(str)
		self.stdout = self.stdout .. str
	end
end

function TestHandlers:tearDown()
	os.exit = self.orig_exit
	io.write = self.orig_write
end

function TestHandlers:testHalt()
	local h = handlers.opcodes[0].handler
	h(self.registers)
	lu.assertEquals(self.exit_code, 1)
end

function TestHandlers:testJmp()
	local h = handlers.opcodes[6].handler
	local target = { value = 50 }
	h(self.registers, target)
	lu.assertEquals(self.registers.pc, target.value + 1)
end

function TestHandlers:testJt()
	local h = handlers.opcodes[7].handler
	local target = { value = 50 }

	-- Case: True (non-zero)
	self.registers.pc = 100
	h(self.registers, { value = 1 }, target)
	lu.assertEquals(self.registers.pc, target.value + 1)

	-- Case: False (zero)
	self.registers.pc = 100
	h(self.registers, { value = 0 }, target)
	lu.assertEquals(self.registers.pc, 100) -- Should not change
end

function TestHandlers:testJf()
	local h = handlers.opcodes[8].handler
	local target = { value = 50 }

	-- Case: True (zero)
	self.registers.pc = 100
	h(self.registers, { value = 0 }, target)
	lu.assertEquals(self.registers.pc, target.value + 1)

	-- Case: False (non-zero)
	self.registers.pc = 100
	h(self.registers, { value = 1 }, target)
	lu.assertEquals(self.registers.pc, 100) -- Should not change
end

function TestHandlers:testOut()
	local h = handlers.opcodes[19].handler
	local char_code = { value = string.byte("A") }
	h(self.registers, char_code)
	lu.assertEquals(self.stdout, "A")
end

function TestHandlers:testNop()
	local h = handlers.opcodes[21].handler
	self.registers.pc = 100
	h(self.registers)
	lu.assertEquals(self.registers.pc, 100)
end

os.exit(lu.LuaUnit.run())
