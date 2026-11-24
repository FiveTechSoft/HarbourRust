# main's return value

Black-box behaviour of real Harbour 3.2 (mingw64, `-gtcgi`, native
Windows 11, November 24, 2026); no Harbour source was read.

- `return <value>` in main is accepted and the value is discarded: the
  process exit code stays 0 for `return 0`, `return(7)`, `return "abc"`
  and `return f()`. Only `ErrorLevel()` sets the exit code (measured:
  `ErrorLevel(3)` then `return 9` exits with 3).
- A returned call, or each call of a returned parenthesized list, still
  runs before main ends (`main_return_call.prg`).
- An early `return <value>` inside IF or FOR ends the program there
  (`main_return_value.prg`).

hbc rewrites main's `return <value>` as a bare `return` when the value is
a literal or a variable, as the call statement followed by `return` when
the value is a call, and as each call in order when the value is a
parenthesized list of those (`return (f(), g(), 2)`). Any other value
form in main (operators, indexing) is still a compile error, so a value
that could fail at run time is never dropped unseen.

`expected/*.windows.out` are the Harbour outputs; the `.linux.out` files
have the same bytes with LF line ends.

Kept as compile errors on purpose: a value return inside a FOR EACH body
(the loop variable's borrow checks stay, tests/t346 and t1556) and
`return ALTD()` (ALTD() is accepted only as a statement, tests/altd-stmt).
