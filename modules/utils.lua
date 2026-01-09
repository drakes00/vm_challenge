--- Loads the binary challenge file.
-- Reads 'challenge.bin' as a binary file, interpreting it as a sequence
-- of 16-bit little-endian integers.
-- @return table A list of 16-bit integers representing the program memory.
local function loadBinary()
	local handle = assert(io.open("challenge.bin", "rb"))
	local content = handle:read("*all")
	handle:close()

	-- Convert the binary string to a table of bytes (0-255)
	local bytes = {}
	for i = 1, #content, 2 do
		local byte1 = string.byte(content, i)
		local byte2 = string.byte(content, i + 1) or 0 -- Use 0 if no second byte

		-- Combine into a 16-bit value (little-endian: byte1 is LSB, byte2 is MSB)
		local short = (byte2 << 8) + byte1

		table.insert(bytes, short)
	end

	return bytes
end

--- Dumps the contents of a table to stdout.
-- Iterates over the table and prints each key-value pair.
-- @param t table The table to inspect.
local function dump(t)
	for key, value in pairs(t) do
		print(key, value)
	end
end

return {
	loadBinary = loadBinary,
	dump = dump,
}
