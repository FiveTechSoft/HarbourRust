# Timestamp phase 2: bounded date/time formats

Own MIT implementation on 9679329ce2fb9b97bd0ad6c2e291527b026ee4c3.
Julio Ponce's MIT examples and Harbour 3.2 outputs are specifications only.
No implementation or diff from Julio or Harbour was copied. No workflows,
push or publication are part of this delivery.

## Scope

Adds hb_TToC(value [, date-mask [, time-mask]]) and
hb_DToC(value [, date-mask]) for ordinary native Linux x86-64. The value can
be a Date or runtime Dyn Date/timestamp. Other runtime kinds throw through
the existing catchable type-error path. Owned invalid temporaries release
before throwing. Results are ordinary owned strings.

Omitted date masks follow SET DATE/CENTURY. Omitted time masks use
HH:MM:SS.fff. An explicitly empty date mask suppresses the date and its
separator; a nonempty date with an empty time mask keeps the separating
space. hb_DToC renders only the date. Empty dates blank their date digits;
time-only timestamps retain their time. Token case is insensitive.

Admitted custom masks are literal ASCII, at most 128 bytes, date masks at
most 10 bytes. Date tokens: YYYY or YY, MM, DD. Time tokens: HH, MM, SS, fff.
Each field may occur only once. Punctuation is preserved. Other alphabetic
characters, repeated fields, odd widths, longer date masks and computed
masks are named compile-time limits. In particular AM/PM, names, locale
words and rounding from fractional widths other than fff are NOT included.
These limits are deliberate: black-box Harbour probes showed unusual
truncation/repeated-field behavior for broader masks, so this increment
rejects them instead of pretending to match.

No timestamp comparison, general Empty(Dyn), wider container bridge or
Windows/Mac/LLVM/thread/macro runtime support is added. e16/e17 are NOT
claimed resolved. Their next blockers remain outside this format package.
Existing phase1 diagnostics and limits are unchanged. User functions named
hb_TToC/hb_DToC keep priority over the builtins.

## Verification

Run from the repository root with the real hbmk2 installation executable:

    python tests/timestamp-phase2/check.py --compiler target/release/hbc --hbmk2 /path/to/harbour/bin/linux/gcc/hbmk2 --output /tmp/ts2-check

The output directory must not exist. The gate has 61 rows: five own programs
with fresh Harbour differential output in four Linux modes (20 exact
executions); four own runtime-error executions; four own user-override
executions; seven strict final balance checks; 18 unsupported-profile
rejections plus three override-emission checks; five named format limits. Runtime
errors check 404 catches and ownership, not equivalence to Harbour Error
objects. The user-override fixture is not a Harbour differential: the
exploratory oracle link reports duplicate RTL symbols. That failure is not
counted as a pass.

Original t03/t08 run unmodified in four modes each with fresh Harbour
3.2.1dev r2610242111 output and separate strict final DELTA=0 checks. Their
source hashes and raw logs are included. A seeded exploratory date-mask
matrix also matched Harbour, but is not counted in the gate totals.

Final guards require exact stdout, rc=0 and empty stderr. Missing DELTA alone
never means success. No final-balance guard is interpreted as a general
proof of memory safety.

Regressions: timestamp1 39 exact executions plus two stream checks and 13
balances; B2 115; B1 152; A1 and A2 pass; Linux manifest 1174 exact outputs;
Rust 99; PE emission/diagnostics only 1909 PASS, 22 known mismatches, 0 FAIL.
The 622 two-target negatives are identical to the B2 baseline, including 13
known mismatches. No PE/Mac runtime claim is made.

Regenerate the own C helper with tests/generate_timestamp_asm.py. Its recipe
records source/assembly/compiler hashes and the existing five-call external
whitelist. generated/hrtimestamp.s is tracked compiler source, not a
disposable emitted test assembly. The review tar includes no executable,
object, or disposable assembly and carries a SHA manifest and compiler SHA.
