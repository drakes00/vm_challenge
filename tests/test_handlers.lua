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

function TestHandlers:testSet()
	local h = handlers.opcodes[1].handler
	local reg = self.registers.reg[1]
	local val = { value = 123 }
	h(self.registers, reg, val)
	lu.assertEquals(reg.value, 123)
end

function TestHandlers:testEq()
	local h = handlers.opcodes[4].handler
	local dest = self.registers.reg[1]

	-- Equal case
	dest.value = 0
	h(self.registers, dest, { value = 10 }, { value = 10 })
	lu.assertEquals(dest.value, 1)

	-- Not equal case
	dest.value = 1
	h(self.registers, dest, { value = 10 }, { value = 20 })
	lu.assertEquals(dest.value, 0)
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

function TestHandlers:testAdd()
	local h = handlers.opcodes[9].handler
	local dest = self.registers.reg[1]

	-- Simple addition
	h(self.registers, dest, { value = 10 }, { value = 20 })
	lu.assertEquals(dest.value, 30)

	-- Addition with modulo
	h(self.registers, dest, { value = 32760 }, { value = 10 })
	lu.assertEquals(dest.value, 2) -- (32760 + 10) % 32768 = 32770 % 32768 = 2
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
