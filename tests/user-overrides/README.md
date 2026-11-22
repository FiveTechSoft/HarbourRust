# Internal ValType calls and user overrides

This patch is based on b69b2fb78316c18b75f7d60b4603856eb20a4156 on a new local branch. It does not change fix-user-descend or main.

A source-level ValType call must still resolve to the user's function. Compiler-created ValType calls used to implement HB_ISCHAR and related predicates, and the checking/emission paths for HB_ISSTRING, must not. Those three construction sites now use a private name containing a NUL byte, which the source identifier lexer cannot produce. is_builtin recognizes that exact internal name before consulting USER_FUNC_NAMES. No user function is removed from the override set.

Regression internal_valtype.prg defines ValType, Descend and Time. Its direct ValType call returns USER, Descend(3) returns 30 and Time() returns T. The predicate cases continue to inspect the actual values. The base compiler rejects the new fixture because it tries to pass an integer to the user's string-specialized ValType. The fixed compiler matches the explicit expected bytes.

The pins are explicit regression expectations, not newly obtained Harbour oracle captures. Run on Linux or Windows with:

    python tests/user-overrides/check.py --compiler /path/to/hbc

The root manifest also checks PE emission of the new case. This runner executes both cases with and without instrumentation. The Windows expected pin uses CRLF and is marked -text. Native Windows execution has not been performed for this patch.

Local validation with Rust 1.100.0:

- Units: 91 passed, 0 failed.
- User-override runner: 4/4 Linux cases exact, including instrumentation.
- New regression also exact with external as/ld, with and without instrumentation.
- Existing Descend/Time fixture exact with both base and fixed compilers.
- PE gate: 1884 PASS, 22 KNOWN-MISMATCH, 0 FAIL. Emission/diagnostics/CLI only, not Windows execution. Base compiler against the added fixture: 1883 PASS, 22 KNOWN-MISMATCH, 1 FAIL, solely the new regression.
- FILE: 22 byte-exact execution/rejection checks.
- Transform check: exit 0.
- Round check: exit 0, ALL GREEN. An earlier 30-second bounded attempt timed out; the final 70-second allowance completed.
- The complete ATokens check did not finish within 120 seconds and was stopped. No complete ATokens or Val pass is claimed for this patch.

No remote CI, PR or branch push was performed. No workflow, release or tag was changed. No claim about Descend implementation provenance is made. The patch does not implement new predicate argument shapes or change the existing named rejections.
