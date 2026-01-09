#!/usr/bin/lua

-- runit.lua
-- Author: Maxime PUYS
-- Created: 2026-01-08
--
-- Description: Interpreter for Synacor Challenge

local handle = assert(io.open("challenge.bin", "rb"))
local content = handle:read("*all")
handle:close()

-- Convert the binary string to a table of bytes (0-255)
local bytes = {}
for i = 1, #content, 2 do
	local byte1 = string.byte(content, i)
	local byte2 = string.byte(content, i + 1) or 0 -- Use 0 if no second byte

	-- Combine into a 16-bit value (big-endian)
	local short = (byte2 << 8) + byte1

	table.insert(bytes, short)
end

local registers = {
	pc = 1,
}

print(bytes[registers.pc])
