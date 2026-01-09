BIN_FILE=challenge.bin

exec:
	@lua runit.lua $(BIN_FILE)

disas:
	@lua runit.lua $(BIN_FILE) -d

test:
	@for f in tests/test_*.lua; do \
		echo "Running $$f..."; \
		lua $$f || exit 1; \
	done

debug:
	@od -An -t u2 -w2 -v challenge.bin | awk '{printf "%04x: %05x\n", NR-1, $$1}' | less
