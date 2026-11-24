# Live TO evaluation in scalar LLVM FOR

Own MIT follow-up on 284b976c86b12972d3f8d0945855b3409ffc5507.
No push, publication or workflows. Fresh Harbour source/output is used
only as a specification. No supplied implementation or cambio.diff.
Julio Ponce's MIT ASort regression attribution remains unchanged.

The native backend was fixed in 284b976c. The independent LLVM scalar
lowering still cached TO. Its TO expression now emits in the condition
block, before loading the current counter. START remains outside the
loop. No new types, runtime helpers or other admission changes.

Before/after evidence: intact t146 and an own live-bound fixture gave
native exact but traced/untraced LLVM mismatches before this change.
They now match fresh Harbour bytes, rc0 and empty stderr. The complete
gate adds five existing FOR sources, for7sources x3routes=21 exact fresh
Harbour runs (7native,14LLVM). It covers calls, mutable TO, counter-based
TO, negative step, LOOP, EXIT, zero-body loops, nesting, fixed-array
writes and counter reuse. The existing t48 input was tried but Harbour
rejects its late LOCAL declaration. That failed experiment is preserved
and excluded, not normalized into an original or parity claim.

The separate regressions.py runs206 unchanged sources selected by the
existing experiments/llvm-scalar/check_regressions.py corpus. Each runs
native and traced/untraced LLVM, for618runs. These compare exact native
bytes/rc/stderr, not fresh Harbour and not golden files. The selected
source list is retained in the script, not rediscovered from globbing.
Source copies, hashes and command/cwd/rc/stdout/stderr records are kept.

An initial extra trace_at at the condition broke the existing trace
canary counts. It was removed before completion. The final LLVM change
only moves TO emission; existing trace interning canary12checks passes
unchanged. This preserves the prior static trace-update inventory; it is
not a new promise of trace equivalence for errors in repeated TO calls.

Final Rust104 and Linux1177 stdout goldens pass. Broad91array suites,
PE1912/22/0,negative622 and census57/1041 were run in the preceding
native package and are NOT claimed rerun here. Compiler change is only
LLVM scalar emission. PE LLVM and Darwin runtime execution were not
validated. No performance claim or newly closed upstream original.

Reviewer traceability follow-up: t146 is recaptured separately with exact
copied input, input SHA256, hbmk2 SHA256, argv/cwd and separate rc/stdout/
stderr for build and run. The recapture matches the corrected Linux
golden. Windows remains an explicit CRLF adaptation, NOT runtime proof.

    python tests/llvm-for-live-bound/check.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --llvm-lib /path/to/libLLVM.so --output /tmp/llvm-for-gate

    python tests/llvm-for-live-bound/regressions.py --compiler target/release/hbc --hbmk2 /path/to/hbmk2 --llvm-lib /path/to/libLLVM.so --output /tmp/llvm-for-existing
