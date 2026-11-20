# LLVM Darwin ARM64 bridge, review stage

Own MIT runtime, separate from native Mach-O emitters. The existing scalar LLVM
IR calls a C ABI: `rt_*`, `ll_main` and the shared linked trace-frame pointer.
On an Apple Silicon macOS compiler host, Linux-target LLVM emission now selects
this Darwin sidecar. This preserves the unchanged feasibility invocation
`--target=linux --experimental-llvm`. No workflow, sample or existing test changes.
Other hosts/targets retain their previous sidecar. Intel Darwin is still pending.

The runtime has main, raw Darwin write/exit, formatted/raw strings, pending
spaces, literal/computed integer fields, fixed-array bound and increment errors,
and the existing LLVM linked trace-frame layout. It does not use x18, libraries,
Harbour code, a VM, the native backend translator or new frontend admission.
It is not a general Darwin runtime: no strings with ownership, FILE/DBF,
threads, EXTERNAL, VAS, floats or unsupported LLVM statements are added.

## Verification layers

`cross.py` uses the externally supplied LLVM C API to emit real ARM64 Mach-O
objects from IR or assembly. Set HARBOUR_LLVM_LIB to the LLVM shared library.
`cross_check.py --compiler HBC --rustc RUSTC --lld LD64_LLD --output DIR` checks
52 unchanged existing experiment PRGs plus the exact workflow-extracted sample,
in traced/untraced modes. It compares executed ARM64 instructions against the
Linux native compiler's rc/stdout/stderr. Untraced error expectations omit the
native Callstack suffix explicitly. This is not a Harbour oracle comparison.
Three long benchmarks (corpus/perfextra/smoke) are excluded, not shortened.
The first exploratory benchmark hit the emulator instruction cap, not a product
build or native execution failure. The exact feasibility sample is not excluded.

`emulate.py` loads Mach-O segments and hooks only Darwin write/exit. It models
successful writes or explicit synthetic short writes/EINTR. It does not model
dyld, kernel, code signing, hardware or the actual macOS startup environment.
`abi.py --lld LD64_LLD --output DIR` seeds x19-x29, SP and d8-d15 lower64 across
all returning helpers, and detects two isolated assembly counterfactuals.
The output canary originally overcounted its first integer field by one space;
that test expectation was corrected to the10-column field before final runs.

`native_check.py --compiler HBC --output DIR` requires a real Apple Silicon Mac,
extracts the unchanged workflow sample and runs its exact emission/clang/link
commands. It checks exact smoke bytes, rc0 and empty stderr. Native execution
and macos-feasibility success remain unverified until this is run on macOS.
Cross-emulation is supporting evidence, not a substitute for that milestone.
