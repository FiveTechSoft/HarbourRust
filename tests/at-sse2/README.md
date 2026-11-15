# At one-byte bounded SSE2 scan

Only needle length1 uses the new scan. Sixteen-byte text loads occur only with
at least16 bytes remaining. Needle loads exactly1 byte; scalar tail stays in
bounds. Empty or multi-byte needles retain original helper. No call-site,
retained-argument, ownership or general substring semantics change.

check.py: fresh Harbour694428e gtstd all256 needle byte values, text lengths
0/1/15/16/17/31/32/33/65, missing/first/last, embeddedNUL, empty/multi-byte;
ELF/PE normal/instrumented exact, Mach-O emission. Later text evaluation mutates
the needle owner; snapshot behavior stays correct. Post-owner hb_memcheck0.

abi.py: native encoder,4096 all-byte/alignment cases per configuration, ELF/PE
run and Mach-O emission, normal/instrumented, GPR callee-saved, XMM6-15 preserved,
stack alignment, logical allocation balance and final registry0.

guard.py: native encoder ELF only,1960 boundary cases with inaccessible pages
on BOTH sides of text and needle. Text length0..65, missing/first/last, both
page edges, bytes0/1/127/128/255. Needle1 byte immediately before guard page.
Empty-needle fallback gets inaccessible pointers. Includes ABI/registry checks.
No native Windows guard-page or native Mac run claim.

Build tests/hasm-sse2/driver.rs for --driver. Other arguments mirror neighboring
suites: --compiler --hbmk2 --output, optional --wine --wine-prefix. ABI requires
Wine options. Driver emits ELF/PE/Mach-O directly through tested hasm encoders,
not GNU as. No padding, sentinels outside strings or unbounded loads allowed.

Limits: byte-codepage only; no Unicode/collation semantics added. General
multi-byte search unchanged. SSE2 is the x86-64 baseline; no AVX dependency.
Performance is same-machine complete-loop timing, not intrinsic latency or
application speedup. Native Mac execution is not available in this gate.
