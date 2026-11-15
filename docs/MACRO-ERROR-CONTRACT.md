# Macro error-contract proposal

BASE c6561a106f45a15be3707956ea87c41a1a85a747. Proposal only: the owner's runtime/compiler files have not been edited in place.

## Selected profile and exact fixtures

The approved profile is terminal-headless. It intentionally omits Harbour's interactive Alert box and Quit/Retry prompt. That omission is a documented divergence from the default -gtstd UI, not full UI parity. Within the selected profile the checks are strict: separate raw stdout, raw stderr, natural exit 1, no path, no Callstack header, uppercase procedure name, and the two trailing spaces after each Called-from frame.

specs.json replaces the meaning of the three invalid posx expectations. Their existing kind cannot express this contract: posx requires empty stderr. The proposed manifest change marks these rows as migrated to the separate checker; the separate checker MUST be run along with the ordinary battery. Do not count removal of those posx rows as three passes. This unit does not extend every historical manifest runner.

Unix stderr bytes are:

    \nError BASE/1449  Syntax error: &\nCalled from MAIN(4)  
    \nError BASE/1003  Variable does not exist: X\nCalled from MAIN(5)  
    \nError BASE/1081  Argument error: +\nCalled from MAIN(4)  

No final LF follows those trailing spaces. Windows uses CRLF. The expected program stdout is LF + before on Unix, CRLF + before on Windows. It excludes only Alert/UI bytes, not the newline of the program's QOut. If the existing compiler QOut differs on PE, the end-to-end checker must fail; the isolated adapter cannot establish QOut parity.

The repository publishes only the selected terminal-profile fixtures. Full official Alert/UI captures are retained in the separately delivered oracle evidence archive, not at repository fixture paths, so specs.json does not reference them. The terminal stderr fixtures are exact copies of the official stderr, unnormalized. Program stdout fixtures are the known before prefix, not a lossy conversion of the Alert box.

## Proposed hrm_fail patch

TERMINAL.patch changes only the two fatal adapters in src/hbc.rs. It emits the message and native language-frame chain to stderr, derives procedure and line from trace metadata rather than a filename string, and exits 1 without entering hbc_panic_exit's legacy Callstack formatter. The exit instruction shapes deliberately avoid finalize_trace's broad legacy-exit replacement; a guard in the reproduction recipe checks this. It preserves the current evaluator C ABI and does not need regenerated hrmacro assembly for this terminal-only step.

The formatter uppercases ASCII procedure names at output. It writes no stdout, allocates no heap, and does not use the compiler string cache/registry. Nested real generated traces, worker threads, Mach-O, DBF cleanup and unusual metadata have not been exercised. Fatal process exit does not prove runtime resource cleanup or recoverability. The patch is for the owner's review/application; it is not an in-place modification of their front.

## Recoverable, deferred and substitutable error design

Do not implement recovery by jumping from hrm_fail into the present hbc_seq_throw_error. That helper currently catches a borrowed string, not an Error object. A pointer into hrmacro's stack-local V_ERR.ebuf would be dangling after unwind. Jumping out also skips owned strings, AST/scratch cleanup and compiler temporary cleanup. That would not be strict ErrorBlock semantics.

Proposed replacement interface, to be implemented as one coordinated evaluator redesign:

    hrm_status hrmacro_try_eval(text, length, context, result_out)

result_out is a tagged success-or-error result, not a Dyn cell pretending to be an error. A successful value transfers its documented compiler ownership. An error owns or copies a stable descriptor containing subsystem BASE, subCode, genCode, operation, description, canSubstitute/canRetry/canDefault and any required args. Add one destructor for the result so failure and substitution cannot leak either branch. Error descriptor ownership must survive returning from the C parser. Fix the exact struct/ABI only with the code owner, including Win64 wrappers and nonvolatile preservation.

The C evaluator must never call the user handler or the terminal adapter during recursive evaluation. Parse/fold and runtime evaluation retain deferred errors and ordering; constant folding may remove an error node before dispatch. Syntax failure is returned after all C-owned scratch is released. The host boundary then constructs the real Error value, dispatches the active ErrorBlock, and applies substitution or the handler's BREAK/RECOVER through the language unwind path after compiler temporaries are safe. Unhandled errors select the terminal formatter above. The top recoverable boundary does not exist in the current patch and is NOT claimed as implemented.

### BASE/1340 is substitutable, not automatically fatal

The paired official runs in oracle-zero/ settle a material point. Default errsys.prg explicitly returns 0 for EG_ZERODIV when canSubstitute is true. With the default handler, both ELF and PE print before, then zero, then after, naturally exit 0 and have empty stderr. The INIT autoquit helper is present but no Alert appears and no Quit is needed for this error.

With ErrorBlock({|e| Break(e)}) the existing mixed-gates/zero-origin evidence instead observes subCode 1340 for both literal macro text and a LOCAL text variable. Therefore the existing mkint(0) is consistent with the default substitution result but incorrectly bypasses custom ErrorBlock semantics. Equally, replacing it with a fatal mkerr/exit would break the default handler. The redesign must create a deferred, substitutable error and let the current handler decide. This proposal intentionally leaves the hard-coded branch unchanged rather than shipping either wrong shortcut.

## Verification and remaining gate

The actual hrmacro.c at BASE was compiled and linked against the proposed fatal adapter, with a small C test client providing synthetic MAIN trace metadata and allocator stubs. All three error texts were evaluated by that C evaluator on ELF and PE/Wine. The separate checker matches raw stdout/stderr and natural exit1 for all six adapter runs. This is adapter-level evidence, NOT the PRGs compiled through the product frontend. It does not verify source-to-trace mapping, QOut, finalize_trace emission, instrumented registry, recoverable errors or full error objects.

The exact proposed patch is checked against the exact BASE source. Before publication as a fix, the code owner must compile the patched compiler, run check.py --compiler on the real three PRGs on both targets, run instrumented ownership/error-unwind gates, and review recovery/substitution separately. No product-wide PASS is claimed. The separate checker exits nonzero for timeout, compile failure, signal or any byte/exit mismatch, and retains raw files.

## Limits

Terminal-format proposal plus explicit specification correction. Recoverable ErrorBlock semantics, Error object construction, handler substitution and cleanup remain design work, not completed code. Alert/Quit UI is intentionally omitted. PE was run under Wine, not native Windows. Existing global diagnostic behavior outside hrm_fail is unchanged. The third probe is a mixed-type plus error, not a wrong-arity function error.
