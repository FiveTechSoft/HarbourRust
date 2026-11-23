# hb_ATokens() - string tokens over a 1..n-character delimiter

`hb_ATokens(s [, cDelim [, lSkipStrings [, lDoubleQuoteOnly]]])` returns
a dynamic array of the tokens of `s`. Behaviour is pinned black-box by
the oracle sweep under `tests/atokens-bb/` (1649 rows, byte-exact);
this directory keeps the two original smoke programs.

- explicit delimiter string: a boundary is a full 1..n-byte delimiter
  match, empty tokens are preserved and the run is NOT collapsed
  (",a," -> {"", "a", ""}, "a,,b" -> {"a", "", "b"}).
- no delimiter (or a non-string one, or an EMPTY delimiter string): the
  delimiter is the single space, empty tokens are dropped and the edges
  produce nothing ("a  b   c" -> {"a", "b", "c"}, "  x y  " -> {"x",
  "y"}); the empty string yields {""}.
- logical .T. as the delimiter: a single whole-string token.
- lSkipStrings skips over quoted stretches when finding boundaries;
  lDoubleQuoteOnly restricts the quote set to the double quote.

Each token becomes an owned string cell (tag 2, data pointer) in the
array block. Tokens of a string temporary borrow its bytes during the
scan (owned temporaries release after the call).

`expected/*.windows.out` is real Harbour 3.2 output (hbmk2
-comp=mingw64 -gtcgi, native Windows 11); the Linux files are the same
bytes with LF line ends.
