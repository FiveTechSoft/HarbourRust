# Isolated ARM64 numeric runtime building blocks

This extends the isolated experiment, not production hbc. It does not change
`src/`, the real ARM rejection, or the scalar harness's supported AST boundary.
Runtime arithmetic remains rejected by that harness. No new ARM source program
is admitted by this increment.

## Own generated code

- Integer +, - and * stay exact while the signed result fits. Overflow converts
  both original operands separately to binary64 before performing the operation.
  Signed high multiplication checks product overflow. Division returns a double
  and reports a zero divisor separately, rather than dividing integers first.
- Mixed finite i64/binary64 kernels. Integer and float registers are distinct:
  x18 is forbidden, but d18 is a legal floating-point register. No full NaN
  payload/signaling-NaN arithmetic contract is claimed.
- Numeric metadata: asymmetric width 10/20; decimals are max for +/-, sum for *,
  and 2 for /, with the bounded decimal-count limit 435. Separate tests check
  subnormals, signed zeros, infinities/NaNs and adjacent width-boundary values.
- Value/format glue accepts payload/format pairs, preserves integer provenance
  at input and returns runtime provenance for computed integers. Floating values
  use `(length << 16) | decimals`. Explicit status codes signal zero divisor,
  invalid format and decimal-limit errors. These statuses are not language
  exceptions, error text, trace records or TRY unwinding.
- Binary64 normalization, half-up rounding, ASCII composition, width padding,
  nonfinite stars, and the mixed-local integral fast path are emitted ARM64.
  No `printf`, C runtime, Rust float formatter or external number-format library
  is called by that code. An explicit bounds check before FCVTZS handles ARM's
  saturation differently from x86's indefinite result, especially at 2^63.

The encoder is shared with the older scalar experiment; these additional
operations do not change existing instruction words. All numeric probes remain
outside AST lowering. The small host Rust decimal model is a development model,
not generated program code. Generation needs Rust std only. Python packages,
LLVM, native GNU as/ld and x86 execution are development oracles only.

## Run

Copy the entire parent `arm64-native` directory outside the checkout, then use
its existing development requirements in a Python environment:

```sh
work="$(mktemp -d)"
cp -R experiments/arm64-native/. "$work/"
python3 -m venv "$work/venv"
"$work/venv/bin/pip" install -r "$work/requirements-dev.txt"
"$work/venv/bin/python" "$work/numeric/run-checks.py" --repo "$PWD"
```

The runner needs Linux x86-64 and GNU `as`/`ld` for the independent current-x86
formatter control. It pins the current `src/hbc.rs` hash before extracting that
helper. `RUSTC` selects the Rust compiler. Optional `LLVM_SHARED_LIBRARY` enables
18 new instruction-word comparisons against an independent LLVM object.
The original parent runner can also be rerun to check the old scalar cohort.
Neither runner edits the source checkout. Results and binaries are written only
into the copied experiment directory.

## Measured checks

The review evidence separates these counts; they are not compatible-program
counts and must not be summed as language support:

| Check | Measured controls |
| --- | ---: |
| i64-input arithmetic kernels | 49,444 |
| Mixed finite arithmetic kernels | 21,764 + 20 invalid-kind controls |
| Metadata fields | 61,140 |
| Payload/format ABI glue | 12,784 |
| ARM normalized digit image | 7,802 |
| Ordinary ARM ASCII compose vs host model | 5,300 + 5 no-output errors |
| Ordinary/mixed ARM format vs host model | 5,600 + 5 no-output errors |
| Emitted ARM formatter directly vs current native x86 helper | 2,524 |
| Shared encoder unit tests | 5 |
| New encoding words vs independent LLVM | 18 |

The ordinary/mixed host model is itself compared to the current x86 helper on
2,524 cases. The direct ARM/x86 run is additional evidence, not a chain of model
claims. Values include rounding carries, binary64/i64 extrema, 2^53 boundaries,
subnormals, signed zero, nonfinite formatting and decimal-count limits. Output
canaries and preserved registers are checked where the ABI requires them.

## What remains open

FPCR=0 (nearest-even, subnormals enabled) is an explicit precondition of these
isolated runners. Actual program entry must set or validate and preserve the
required floating-point environment before use. Buffer callers must provide at
least 456 writable bytes. The composer returns an error for out-of-profile
metadata or an oversized formatted result; it does not provide the language's
error/trace path. Count 435 alone does not guarantee that every possible finite
value fits the 456-byte buffer.

AST integration, full numeric call/local ABI, ownership interactions, runtime
error descriptions/call stacks, catch/unwind behavior, pending-console state and
all remaining language/runtime families still need their own implementation and
review. Tests use current x86 hbc and arithmetic models, not a fresh independent
Harbour VM oracle. No macOS compiler build, loader, Darwin kernel, Apple Silicon
execution, Apple signing-policy verdict or Gatekeeper result is established.
