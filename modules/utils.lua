--- Loads the binary challenge file.
-- Reads the specified binary file, interpreting it as a sequence
-- of 16-bit little-endian integers.
-- @param filename string The path to the binary file to load.
-- @return table A list of 16-bit integers representing the program memory.
local function loadBinary(filename)
	local handle = assert(io.open(filename, "rb"))
	local content = handle:read("*all")
	handle:close()

	-- Convert the binary string to a table of 2 bytes words in little endian.
	local mem = {}
	for i = 1, #content, 2 do
		local b1 = string.byte(content, i)
		local b2 = string.byte(content, i + 1) or 0
		table.insert(mem, b1 + (b2 << 8))
	end

	return mem
end

--- Dumps the contents of a table to stdout.
-- Iterates over the table and prints each key-value pair.
-- @param t table The table to inspect.
local function dump(t)
	for key, value in pairs(t) do
		print(string.format("0x%04x (%d): %s", key, key, value))
	end
end

--- Converts a Lua 1-based index to a VM 0-based address.
-- Helper function to map internal Lua table indices to the architectural address space.
-- @param addr number The 1-based index from the Lua memory table.
-- @return number The corresponding 0-based address in the VM architecture.
local function realAddr(addr)
	return (addr - 1)
end

return {
	loadBinary = loadBinary,
	dump = dump,
	realAddr = realAddr,
}
