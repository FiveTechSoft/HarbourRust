# Benchmark methodology: harbour/core vs HarbourRust

Scope: the subset of Harbour syntax that HarbourRust implements today. Three
microbenchmarks; this is NOT a general language performance claim.

## Frozen versions

- HarbourRust compiler: commit 99f32d8df23893996e413b1a0d2a8e395a1eeba5
  (hbc + GNU as + GNU ld, naive code generation, no optimizations at all).
- harbour/core: commit 694428e1c12f726675b19324d62167fa77d68185
  (Harbour 3.2.1dev r2610242111), depth-1 read-only clone, built locally with
  gcc 11.4.0, no contribs. Two configurations measured:
  pcode (default, VM-interpreted) and -gc3 (REALCODE, C generated + gcc).
- Machine: Linux x86-64, 2 cores, 2 GB RAM. Every number is the median of 5
  runs (3 for the slow pcode contrast runs).

## Programs

The same source file feeds both compilers (copied byte for byte between the
.prg and .prg names). Only syntax already implemented by HarbourRust is used;
no syntax was added to fabricate tests.

- b1_int: for-loop of 1e8 iterations, accumulator bounded below 2e6 so that
  neither side leaves int64 range (Harbour integers overflow INTO double;
  HarbourRust wraps i64 - both behaviours kept out of the measurement).
- b2_str: 3e6 iterations of =, <, >, <> between two EQUAL-LENGTH strings
  (45 bytes). Harbour `=` with EXACT OFF is an asymmetric prefix compare;
  equal lengths make its semantics coincide with HarbourRust byte equality.
- b3_call: 2e7 iterations calling a 0-argument function that returns 42.
- Only +, -, * are used. Harbour `/` is float division while HarbourRust `/`
  is integer division, so division is excluded.

## Equivalence checked before timing

- Output checksums identical in all configurations:
  b1_int 4900499752500003, b2_str 21000000, b3_call 840000000.
  Comparison is done with whitespace normalized: Harbour `?` right-pads
  numeric output with spaces and HarbourRust does not. The VALUES are
  identical; the output STREAMS are not byte-identical.
- Equal work verified by inspection, not only by equal results: the
  HarbourRust assembly of b3_call contains a real `call hbc_fn_f` inside the
  loop (the compiler performs no constant folding or dead-code elimination);
  the -gc3 generated C keeps the loop as a C goto-loop and each iteration
  goes through hb_xvmFunction, so gcc cannot inline the call away.

## Optimization contrast

hbmk2's default C flags already are -O3 (verified with `hbmk2 -trace`), and
the Harbour libraries themselves were built with -O3. As a contrast, pcode
and -gc3 binaries were also built with explicit -O2 and with
-O3 -march=native (via `-cflag=`, verified present in the gcc command line).
Results changed by at most a few percent in both directions, so the reported
speedups do not depend on missing C optimization on the Harbour side.

## Limits

- Three microbenchmarks on the implemented subset only.
- Harbour carries full dynamic semantics (dynamic types, codeblocks, macro
  evaluation) that this PoC does not implement; the comparison covers only
  what both sides can run.
- Linux native only. Wine is used for correctness (the 59-case battery runs
  identical there), not for speed claims.
- Compile times on these tiny programs are a few milliseconds vs around a
  hundred; treat them as indicative of the pipeline shape (direct asm vs
  C round-trip through gcc), not as a general ratio.

## Reproduce

    # HarbourRust
    ./hbc bench/b1_int.prg /tmp/b1.s --target=linux && as -o /tmp/b1.o /tmp/b1.s && ld -o /tmp/b1 /tmp/b1.o
    # harbour/core (pcode and -gc3), from a harbour/core build tree
    hbmk2 -quiet -gtstd -w0 b1_int.prg
    hbmk2 -quiet -gtstd -w0 -gc3 b1_int.prg -ob1_gc3
    # explicit-optimization contrast
    hbmk2 -quiet -gtstd -w0 -gc3 -cflag=-O2 b1_int.prg -ob1_gc3_o2
    hbmk2 -quiet -gtstd -w0 -gc3 -cflag='-O3 -march=native' b1_int.prg -ob1_gc3_o3n
