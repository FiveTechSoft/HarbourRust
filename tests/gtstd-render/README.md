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
