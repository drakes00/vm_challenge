debug:
	od -An -t u2 -w2 -v challenge.bin | awk '{printf "%04x: %05x\n", NR-1, $$1}' | less
