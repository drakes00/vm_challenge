local lu = require("deps.luaunit")
local handlers = require("modules.handlers")

TestHandlers = {}

function TestHandlers:setUp()
	self.mmu = {
		registers = {
			pc = 100,
			sp = 1,
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
		},
		stack = {},
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
	h(self.mmu)
	lu.assertEquals(self.exit_code, 1)
end

function TestHandlers:testSet()
	local h = handlers.opcodes[1].handler
	local reg = self.mmu.registers.reg[1]
	local val = { value = 123 }
	h(self.mmu, reg, val)
	lu.assertEquals(reg.value, 123)
end

function TestHandlers:testPush()
	local h = handlers.opcodes[2].handler
	local reg = { value = 12345 }
	
	h(self.mmu, reg)
	
	lu.assertEquals(self.mmu.registers.sp, 2)
	lu.assertEquals(self.mmu.stack[1], 12345)
end

function TestHandlers:testPop()
	local h = handlers.opcodes[3].handler
	local dest = self.mmu.registers.reg[1]
	
	-- Setup stack
	self.mmu.stack[1] = 54321
	self.mmu.registers.sp = 2
	
	h(self.mmu, dest)
	
	lu.assertEquals(dest.value, 54321)
	lu.assertEquals(self.mmu.registers.sp, 1)
end

function TestHandlers:testPopEmptyStack()
	local h = handlers.opcodes[3].handler
	local dest = self.mmu.registers.reg[1]
	self.mmu.registers.sp = 1
	
	lu.assertErrorMsgContains("Stack Underflow", h, self.mmu, dest)
end

function TestHandlers:testEq()
	local h = handlers.opcodes[4].handler
	local dest = self.mmu.registers.reg[1]
	
	-- Equal case
	h(self.mmu, dest, { value = 10 }, { value = 10 })
	lu.assertEquals(dest.value, 1)

	-- Not equal case
	h(self.mmu, dest, { value = 10 }, { value = 20 })
	lu.assertEquals(dest.value, 0)
end

function TestHandlers:testJmp()
	local h = handlers.opcodes[6].handler
	local target = { value = 50 }
	h(self.mmu, target)
	lu.assertEquals(self.mmu.registers.pc, target.value + 1)
end

function TestHandlers:testJt()
	local h = handlers.opcodes[7].handler
	local target = { value = 50 }

	-- Case: True (non-zero)
	self.mmu.registers.pc = 100
	h(self.mmu, { value = 1 }, target)
	lu.assertEquals(self.mmu.registers.pc, target.value + 1)

	-- Case: False (zero)
	self.mmu.registers.pc = 100
	h(self.mmu, { value = 0 }, target)
	lu.assertEquals(self.mmu.registers.pc, 100) -- Should not change
end

function TestHandlers:testJf()
	local h = handlers.opcodes[8].handler
	local target = { value = 50 }

	-- Case: True (zero)
	self.mmu.registers.pc = 100
	h(self.mmu, { value = 0 }, target)
	lu.assertEquals(self.mmu.registers.pc, target.value + 1)

	-- Case: False (non-zero)
	self.mmu.registers.pc = 100
	h(self.mmu, { value = 1 }, target)
	lu.assertEquals(self.mmu.registers.pc, 100) -- Should not change
end

function TestHandlers:testAdd()
	local h = handlers.opcodes[9].handler
	local dest = self.mmu.registers.reg[1]

	-- Simple addition
	h(self.mmu, dest, { value = 10 }, { value = 20 })
	lu.assertEquals(dest.value, 30)

	-- Addition with modulo
	h(self.mmu, dest, { value = 32760 }, { value = 10 })
	lu.assertEquals(dest.value, 2) -- (32760 + 10) % 32768 = 2
end

function TestHandlers:testOut()
	local h = handlers.opcodes[19].handler
	local char_code = { value = string.byte("A") }
	h(self.mmu, char_code)
	lu.assertEquals(self.stdout, "A")
end

function TestHandlers:testNop()
	local h = handlers.opcodes[21].handler
	self.mmu.registers.pc = 100
	h(self.mmu)
	lu.assertEquals(self.mmu.registers.pc, 100)
end

os.exit(lu.LuaUnit.run())