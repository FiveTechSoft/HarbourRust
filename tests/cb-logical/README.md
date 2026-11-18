# Logical codeblocks and AScan with a codeblock

Issue #1 (3.4): `{|x| x > 2}` was rejected ("codeblock bodies are integer
expressions or NIL-only calls"). A block whose last expression is a
comparison, `.AND.`/`.OR.`/`.NOT.` or a logical literal now returns a
logical: `Eval()` of it is a logical value.

`AScan(a, {|x[, i]| ...})` on a dynamic integer array calls the block with
each element (and its 1-based position) and returns the first position where
it returns `.T.`, or 0. A non-integer element is a clean runtime type error.

Still outside this increment: block parameters other than integers (so
`AScan(aStrings, {|e| e == "z"})`), captures of enclosing locals, assignments
inside a block, and `ASort` with a block.

`expected/*.windows.out` is real Harbour 3.2 output (hbmk2 -gtcgi, bcc,
native Windows 11); the Linux file is the same bytes with LF line ends.
