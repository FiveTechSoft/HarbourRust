# Linux library filenames

Original MIT implementation and probes. Harbour is only an external gtstd oracle.

Run `python3 tests/libname/check.py --compiler /absolute/hbc --hbmk2 /absolute/hbmk2 --harbour-core /absolute/core --output /new/directory`.

The unchanged external tests/libname.prg is verified against the pinned inventory hash, never copied into tests or evidence. Own probes cover names, extensions, directory precedence, embedded NUL, UTF-8 byte strings, the 263-byte split and 262-byte result limits, expression evaluation order, NIL name with an effectful directory, repeated temporary strings, and allocation growth after warm-up. ELF internal and external assemblers must match fresh Harbour stdout/stderr/rc exactly. No output is accepted after a failed build. Timeouts fail closed.

hb_libName takes one or two typed string/NIL arguments. hb_ps takes none. Both are measured only on ordinary x86-64 Linux. Other profiles reject, rather than applying Linux rules to Windows/Darwin. Generic Dyn arguments, argument-count compatibility and non-string conversions remain named limits. The helper returns an owned counted string, clips at NUL and historical path bounds, preserves a directory in the name over the optional directory, adds lib before the basename, and adds .so only when the basename has no extension. A leading dot alone does not establish an extension. hb_ps returns an owned slash.

No native Windows/macOS, sanitizer or multithread claim. The candidate-only hb_memcheck check measures allocation growth, not Harbour memory use.

Nested argument calls retain their normal ownership effects. The outer builtin borrows its argument results, not the inputs those nested calls consume. Hash/array-after-Take negatives check this. Borrowed strings are copied before evaluating the next argument, so `hb_libName(s, Take(s))` keeps the first argument alive when Take consumes its source. The snapshot fixture and instrumented repeat check both the value and zero growth.
