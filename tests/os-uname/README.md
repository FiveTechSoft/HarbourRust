# Linux OS through uname

Original MIT implementation and tests. Harbour is an external oracle only.

Run `python3 tests/os-uname/check.py --compiler /absolute/hbc --hbmk2 /absolute/hbmk2 --harbour-core /absolute/core --output /new/directory`.

OS() on the ordinary x86-64 Linux backend reads the running kernel with uname, then copies system, release and machine into an owned string separated by spaces. It does not invoke a shell or use build-host constants. Each 65-byte kernel field is scanned with a bound. Failure or a malformed record is a runtime error, not a fabricated OS string.

The gate compares own programs and the unchanged, hash-verified external tests/os.prg against fresh Harbour gtstd on ELF internal and external assemblers. It tests string composition, repeated returns and zero allocation growth after cache warm-up. Synthetic kernel records replace only the uname syscall in emitted assembly to check a different machine, maximum fields, empty fields and error paths. Those are deterministic boundary tests, not executions on other platforms. A no-OS program must not emit the helper.

Only no-argument OS() is covered. Windows, Darwin, arm64 and experimental LLVM backends reject by name. Harbour can ignore extra OS arguments; the candidate rejects them as a declared limit. Failure/malformed-kernel paths are fail-closed policy tests, not claimed Harbour equivalence. No native Windows/macOS, sanitizer or thread claim.
