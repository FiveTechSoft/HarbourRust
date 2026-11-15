# Space F64 admission gate

Space accepts exactly one statically typed I64 or F64 count. I64 behavior is unchanged. Finite F64 counts in [-2^63, 2^63) truncate toward zero with CVTTSD2SI, then enter the existing Space helper. Negative and zero converted counts return an owned empty string. Nonfinite and out-of-I64-range values print `Error: Space F64 count out of I64 range` and exit 1 before allocation. This error is not catchable by TRY. No Dyn, mixed numeric LOCAL, default coercion or new by-reference F64 channel.

Parameter inference is numeric-polymorphic like Int/Abs: Space's argument does not force a valid F64 parameter into I64. Bitwise magnitude checks run before CVTT and reject signaling/quiet NaNs and infinities without a floating-point comparison. This change does not attempt huge positive allocations to test conversion.

## Reproduce

Build from the repository root:

```
rustc --edition=2021 -O -C strip=symbols src/hbc.rs -o /tmp/hbc-space-f64
python3 tests/space-f64/check.py --compiler /tmp/hbc-space-f64 --hbmk2 "$HB" --output /tmp/space-f64-gate
python3 tests/space-f64/abi.py --compiler /tmp/hbc-space-f64 --output /tmp/space-f64-bits
python3 tests/space-f64/benchmark.py --compiler /tmp/hbc-space-f64 --hbmk2 "$HB" --output /tmp/space-f64-large --sizes 65536,65537,1048576
python3 tests/space-f64/benchmark.py --compiler /tmp/hbc-space-f64 --hbmk2 "$HB" --output /tmp/space-f64-small --sizes 0,8,64,256,4096
```

HB is real Harbour hbmk2, pinned in the review to commit 694428e1c12f726675b19324d62167fa77d68185. The benchmark uses five timed samples in rotating implementation order, after byte-exact warmups; 300000 calls per 64KiB sample. It also runs the candidate I64 control and a malloc/memset C reference. C has no VM, cache or allocation registry. All process times include startup/shutdown. No CPU pinning or host-noise isolation.

For check.py and abi.py, optional PE/Wine adds `--wine /path/to/wine --wine-prefix /path/to/prefix`. abi.py also needs `--mingw /path/to/mingw/bin --mlib /path/to/mingw/lib`. Wine is not native Windows.

Rebuild the independent Harbour conversion oracle without huge Space allocations:

```
"$HB" tests/space-f64/oracle/oracle.prg tests/space-f64/oracle/count.c -quiet -gtstd -o/tmp/space-oracle
/tmp/space-oracle
"$HB" tests/space-f64/oracle/bits.prg tests/space-f64/oracle/count.c -quiet -gtstd -o/tmp/bits-oracle
/tmp/bits-oracle
```

The pinned Harbour x64 build converts nonfinite and out-of-range F64 values to MIN_I64 as a cast artifact. That accident is explicitly NOT replicated. The native range error is the chosen policy, not a claim of exact compatibility for those values. `bits.prg` observes the conversion only, never allocates boundary-size positive Space results.

Also run the existing full manifest, I64 Space gate, retained-source/ownership gate, StrTran gate and string-cache/accounting gates. The former float-negative fixture is now a positive fixture; the I64 gate still checks every remaining rejection.

## Limits

No unrestricted Harbour dynamic/default coercion, NumLocal or Dyn conversion. Huge admitted positive counts can still hit normal allocation failure. Runtime range error is exit1, not catchable. Owned TRY-error cleanup gaps elsewhere remain. Space F64 inherits the shared fill and its CPU-local performance limits from BASE93e96a4; this is not a new fill or allocator change. No native Windows/macOS performance claim.
