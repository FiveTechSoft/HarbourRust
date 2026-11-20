# LLVM Darwin Intel bridge, review stage

Own MIT runtime, separate from native Mach-O emitters. On a Mac Intel compiler
host, Linux-target LLVM now chooses the Darwin Intel sidecar. Other hosts,
ARM64 sidecar, native emitters and frontend admission remain unchanged.
The workflow and its tests/sample have not changed.

This covers the existing bounded scalar C ABI: main, raw Darwin write/exit,
rt_* printing/space hold, literal/computed integer widths, bound/increment
errors and linked LLVM trace frames. No libraries or native backend translation.
No new FILE/DBF, threads, EXTERNAL, VAS, floats or owned-string support.

`cross.py` requires HARBOUR_LLVM_LIB pointing at an LLVM C API shared library.
`cross_check.py --compiler HBC --rustc RUSTC --lld LD64_LLD --output DIR` builds
real Intel Mach-O objects, links them and emulates x86_64 instructions.52 existing
experiment PRGs plus the unchanged workflow-extracted sample, each traced and
untraced, compare rc/stdout/stderr against Linux native. Untraced fatal errors
explicitly omit the native trace suffix. This is not Harbour oracle parity.
Three long benchmarks corpus/perfextra/smoke are excluded, not shortened. The
workflow smoke is included and independently checked against its exact bytes.

`abi.py --lld LD64_LLD --output DIR` seeds rbx/rbp/r12-r15 and RSP across every
returning rt helper, in normal and synthetic short-write/EINTR modes. Two own
assembly counterfactuals must be detected in both. The emulator poisons rcx/r11
after SYSCALL to reflect real hardware clobbers. This is not native execution:
no dyld, kernel, signing, actual startup environment or real IO faults.

`native_check.py --compiler HBC --output DIR` requires a real Mac Intel host.
It extracts the unchanged feasibility sample and uses the same compile/link
commands with x86_64 in place of arm64. The existing workflow itself is not
modified. Exact bytes,rc0,empty stderr are required. Native Intel remains pending
until run there; cross checks do not close that milestone.
