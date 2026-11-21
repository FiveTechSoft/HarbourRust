# hb_ATokens() - string tokens over a 1..n-character delimiter

`hb_ATokens(s [, cDelim])` returns a dynamic array of the tokens of `s`
(Harbour 3.2 rtl/hbtoken.c with flags 0, hbc_atokens helper in hbc.rs):

- explicit delimiter string: a boundary is a full 1..n-byte delimiter
  match, empty tokens are preserved and the run is NOT collapsed
  (",a," -> {"", "a", ""}, "a,,b" -> {"a", "", "b"}).
- no delimiter: the delimiter is the single space (hbtoken.c 248-252),
  a delimiter RUN counts once and the edges are trimmed
  ("a  b   c" -> {"a", "b", "c"}, "  x y  " -> {"x", "y"}); the empty
  string yields {""}.

Each token becomes an owned string cell (tag 2, data pointer) in the
array block; the quote/EOL flag modes need the third argument and stay
a named rejection. Tokens of a string temporary borrow its bytes during
the scan (owned temporaries release after the call).

`expected/*.windows.out` is real Harbour 3.2 output (hbmk2
-comp=mingw64 -gtcgi, native Windows 11); the Linux files are the same
bytes with LF line ends.
