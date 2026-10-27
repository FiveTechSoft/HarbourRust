# 63zz unary-plus evidence

Reference Harbour parser src/compiler/harbour.y line932 discards unary plus:
`'+' Expression %prec UNARY { $$ = $2; }`.

hk421 succeeds in Harbour but keeps the existing candidate parameter-inference
rejection (a return-only parameter has no independent evidence). Distinct
hk422 adds arithmetic evidence; hk422-hk425 byte-match compiled Harbour -gtstd.
t901 is independently rechecked with Harbour. Unary plus does not change
static types, move/borrow rules or supported increment lvalues.
