# String concatenation assigned back to a literal-initialized local

Issue #1 (3.3): `local c := "a"` followed by `c += "b"` or `c := c + "b"`
was rejected with "type mismatch in assignment to `c`". Only the
empty-literal accumulator (`local c := ""`) was admitted.

A local initialized from a non-empty string literal that is also the target
of a plain `+` assignment anywhere in the function (`concat_assigned_in`,
syntactic) now gets an owned string slot from the declaration, initialized
with an owned copy of the literal - the same shape as the empty accumulator
and the `@s` widening. Locals that are never concatenation targets keep the
borrowed rodata slot; the assembly of every existing program under `tests/`
and `extend/demo` is unchanged.

`expected/*.windows.out` is real Harbour 3.2 output (hbmk2 -gtcgi, bcc,
native Windows 11); the Linux file is the same bytes with LF line ends.
