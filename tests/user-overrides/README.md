# Internal ValType calls and user overrides

This integration is based on main 93073a08. It brings the two user-override commits and the internal ValType fix onto that base as new commits. The original fix-user-descend branch remains unchanged. A direct lexer regression rejects NUL at the start/end of an identifier and inside a predicate argument, while accepting ordinary ValType.

A source-level ValType call must still resolve to the user's function. Compiler-created ValType calls used to implement HB_ISCHAR and related predicates, and the checking/emission paths for HB_ISSTRING, must not. Those three construction sites now use a private name containing a NUL byte, which the source identifier lexer cannot produce. is_builtin recognizes that exact internal name before consulting USER_FUNC_NAMES. No user function is removed from the override set.

Regression internal_valtype.prg defines ValType, Descend and Time. Its direct ValType call returns USER, Descend(3) returns 30 and Time() returns T. The predicate cases continue to inspect the actual values. The base compiler rejects the new fixture because it tries to pass an integer to the user's string-specialized ValType. The fixed compiler matches the explicit expected bytes.

The pins are explicit regression expectations, not newly obtained Harbour oracle captures. Run on Linux or Windows with:

    python tests/user-overrides/check.py --compiler /path/to/hbc

The root manifest also checks PE emission of the new case. This runner executes both cases with and without instrumentation. The Windows expected pin uses CRLF and is marked -text. Native Windows execution has not been performed for this patch.

Validation of this integration is recorded in the package evidence directory. The earlier 17d67730 test results are not substituted for the new-base results. No claim about Descend implementation provenance is made. Existing predicate shape limits are unchanged.
