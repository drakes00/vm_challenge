local lu = require("deps.luaunit")
local handlers = require("modules.handlers")

TestHandlers = {}

function TestHandlers:setUp()
	self.mmu = {
		registers = {
			pc = 100,
			sp = 0,
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
	
	lu.assertEquals(self.mmu.registers.sp, 1)
	lu.assertEquals(self.mmu.stack[1], 12345)
end

function TestHandlers:testPop()
	local h = handlers.opcodes[3].handler
	local dest = self.mmu.registers.reg[1]
	
	-- Setup stack
	self.mmu.stack[1] = 54321
	self.mmu.registers.sp = 1
	
	h(self.mmu, dest)
	
	lu.assertEquals(dest.value, 54321)
	lu.assertEquals(self.mmu.registers.sp, 0)
end

function TestHandlers:testPopEmptyStack()
	local h = handlers.opcodes[3].handler
	local dest = self.mmu.registers.reg[1]
	self.mmu.registers.sp = 0
	
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

function TestHandlers:testGt()
	local h = handlers.opcodes[5].handler
	local dest = self.mmu.registers.reg[1]

	-- Greater than case
	h(self.mmu, dest, { value = 20 }, { value = 10 })
	lu.assertEquals(dest.value, 1)

	-- Equal case (should be 0)
	h(self.mmu, dest, { value = 10 }, { value = 10 })
	lu.assertEquals(dest.value, 0)

	-- Less than case (should be 0)
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

function TestHandlers:testMult()
	local h = handlers.opcodes[10].handler
	local dest = self.mmu.registers.reg[1]

	-- Simple multiplication
	h(self.mmu, dest, { value = 10 }, { value = 20 })
	lu.assertEquals(dest.value, 200)

	-- Multiplication with modulo
	h(self.mmu, dest, { value = 1000 }, { value = 40 })
	lu.assertEquals(dest.value, 7232) -- (1000 * 40) = 40000. 40000 % 32768 = 7232
end

function TestHandlers:testMod()
	local h = handlers.opcodes[11].handler
	local dest = self.mmu.registers.reg[1]

	-- Simple modulo
	h(self.mmu, dest, { value = 10 }, { value = 3 })
	lu.assertEquals(dest.value, 1)

	-- Round modulo
	h(self.mmu, dest, { value = 10 }, { value = 2 })
	lu.assertEquals(dest.value, 0)

	-- Modulo where a < b
	h(self.mmu, dest, { value = 5 }, { value = 10 })
	lu.assertEquals(dest.value, 5)
end

function TestHandlers:testAnd()
	local h = handlers.opcodes[12].handler
	local dest = self.mmu.registers.reg[1]

	h(self.mmu, dest, { value = 0x1F }, { value = 0x0A })
	lu.assertEquals(dest.value, 0x0A) -- 011111 & 001010 = 001010 (0x0A)
end

function TestHandlers:testOr()
	local h = handlers.opcodes[13].handler
	local dest = self.mmu.registers.reg[1]

	h(self.mmu, dest, { value = 0x10 }, { value = 0x01 })
	lu.assertEquals(dest.value, 0x11) -- 10000 | 00001 = 10001
end

function TestHandlers:testNot()
	local h = handlers.opcodes[14].handler
	local dest = self.mmu.registers.reg[1]

	h(self.mmu, dest, { value = 0x000F })
	lu.assertEquals(dest.value, 0x7FF0) -- ~0...01111 = 1...10000. & 0x7FFF = 0x7FF0
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
