# Linux GTSTD console renderer

Original MIT implementation and tests. Harbour is only an external executable
oracle. No Harbour GTSTD source, translated implementation, or library is used.

The measured profile is ordinary Linux x86-64, 80 columns and 25 rows, no
threads. Other profiles keep the previous renderer. Raw OutStd, OutErr and
trace writers keep raw byte output. This is a byte console, not a Unicode
terminal, native window system, terminal decoder, or arbitrary screen API.

The screen retains the original byte and maps control glyphs to '.' only when
writing it. BEL writes byte 7, BS erases a cell and can cross a row boundary,
CR moves to column zero without clearing the row, LF moves down, width 80 wraps,
and scrolling discards the oldest row. Screen state and the emitted stream
position differ. Empty line advances can be deferred across calls until a
visible flush or normal program exit. A BS that restores an already-shown row
must not redraw it. These facts are measured with counted raw channel bytes.

`check.py` compares the same original MIT sources with the external Harbour
GTSTD executable, with no source rewriting, output stripping or normalization.
Its byte-position programs loop over all 256 values at eight positions. The
200 deterministic combination programs stress the state across calls. Every
case runs internal and external assembly variants with instrumentation.

The generated C helper has no allocation or libc dependency. Its sole external
call is the project's raw-byte writer. `generate_gtstd_asm.py` records the C
compiler, flags and hashes; generated static symbols have a private prefix.
The assembly bridge preserves volatile registers used by the existing number
printers. The compiler routes their console writes through the same helper,
while mode zero retains raw output for other callers.

The existing OS syscall-record test now uses OutStd with an explicit LF. It is
a data-builder test, not a console test. Its old synthetic 195-byte maximum
record expected one unwrapped line through '?', which conflicts with the
measured 80-column GTSTD behavior. Its expected bytes are unchanged. The real
OS original and differential fixtures still pass without changes.

The root memory fixtures t886_cached_collision, t1488_stepc_mem_1000 and
t1491_stepd_mem_1000 now use OutStd for their long stream. Checks and expected
bytes are unchanged. t1488 spells the same lazy iif as an if/else because the
existing array-view verifier does not admit that nested iif under OutStd.

Exact fail-mode comparison found a missing final callstack LF in t1480 when a
Dyn render failed before restoring raw mode. The new profile resets console
mode at entry to hbc_panic_exit. No trace-emission, metadata or print_trace code
changes. The existing posx manifest matcher strips LF and misses that defect;
the additional isolation gate compares all stdout/stderr/rc bytes unchanged.

V2 closes deferred lines before fatal diagnostic writes. Runtime helper blocks
that carry the registered exit-1 syscall have their direct stdout writes
preceded by hbc_gtstd_before_fatal. Catchable branches leave before the writes,
so caught TRY does not close the screen. The bridge saves volatile registers,
closes prior output, restores raw mode and leaves diagnostic arguments intact.
No finalize_trace or print_trace changes. Closing in panic_exit would be too
late because the message has already been written, violating byte order.

exits.py distinguishes three contracts: unchanged WAIT sources are compared
exactly to Harbour; fatal fixtures preserve the baseline's registered
rc/stdout/stderr (Harbour handles these errors differently); unsupported QUIT,
ErrorLevel and mixed DispBox remain build rejections, not executed passes.
TRY uses explicit syntax expansion only for the Harbour oracle, with both
sources retained. Pending newlines in caught TRY remain deferred, exactly as
the oracle shows when OutStd writes before the next console text.

WAIT prompt and printable-key echo now enter the same screen state in the
new profile. This fixes ordering after empty QOut and redraw after WAIT+BS/CR.
INKEY and stdin handling are unchanged. The gate uses four printable keys;
control-only WAIT input can keep Harbour waiting and is not a completion
claim. Existing independent WAIT input and INKEY suites remain separate.

DispBox currently rejects any mixed output/control/variables. Thus DispBox
followed by QOut/BS/CR/LF is a named build rejection on baseline and candidate,
not a supported shared-cursor operation. The isolated ordered literal-box
contract and its regression suite remain unchanged.
