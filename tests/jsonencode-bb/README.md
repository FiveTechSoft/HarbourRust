# hb_jsonEncode() - clean-room JSON writer

`hb_jsonEncode(value)` renders a typed scalar, Hash or dynamic array as
JSON (runtime/hrjson.c, generated/hrjson.s via
tests/generate_json_asm.py; black-box fitted from real Harbour 3.2
outputs - no GPL source read):

- hashes and dynamic arrays render in insertion order with no spaces:
  `{"a":1,"b":"txt"}`, `[1,"x",false]`, `[[1,2],[3]]` (nested literal
  cells); empty containers give `{}` / `[]`.
- nil -> `null`, logicals -> `true`/`false`, integers stay exact
  (9223372036854775807), floats keep the item's written decimals
  (1.0 -> "1.0", 2.50 -> "2.50") via the pinned Str() formatter with
  the leading field padding trimmed.
- strings escape `\"`, `\\`, `\n`, `\t`, `\r` and `\u00XX` for the
  other control bytes; a date renders as its DToS text inside a JSON
  string.

Admitted argument types: integer, float, string, logical, date, Hash,
DArr/DArrU/DArr2/DArrS/DArrDyn and Dyn (runtime cell tags
0/9/1/2/3/4/5/8 encode; any other tag is the clean runtime type
error). An owned dynamic temporary is a named rejection. Hash VALUES
above the integer/logical/NIL storage of hbc hashes (strings, floats,
containers) stay out at the HSet checker, not here.

`expected/*.windows.out` is real Harbour 3.2 output (hbmk2
-comp=mingw64 -gtcgi, native Windows 11); the Linux file is the same
bytes with LF line ends. hbc output is byte-identical (14 pins).
