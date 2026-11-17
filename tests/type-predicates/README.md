# Type predicates, hb_Hash() and ValType of hash/block variables

Contributed by Julio Ponce, MIT license. The 19-line change in `src/hbc.rs` is his; the manifest conversion of t415, the limit
fixtures and the oracle gate are added here.

What it does:
- `hb_IsHash`, `hb_IsObject`, `hb_IsNil`, `hb_IsLogical`, `hb_IsDate`, `hb_IsBlock`, `hb_IsChar` with ONE argument are rewritten at parse
  time to `ValType(x) == "<letter>"`; they inherit exactly what ValType accepts and rejects.
- `hb_Hash()` with no arguments is the empty hash literal.
- `ValType` of a statically typed hash variable is "H", of a block variable "B".

Gate (`check.py`): positive programs (Julio's `predicates.prg` and the converted t415) are byte-identical to the external
Harbour 3.2.1dev r2610242111 oracle (not Harbour 4) on Linux (ELF, internal and `--external-as`) and on Windows (mingw oracle under Wine vs PE
internal/external). t415 must print exactly "\nH" on Linux and "\r\nH" on Windows (checked against both oracles).
`neg/` pins the limits as named rejections on both targets.

Limits (honest):
- One argument only; zero or two arguments stay `unknown function`.
- Only forms ValType admits. The oracle-checked positives include `hb_IsChar("a")`, `hb_IsNil(NIL)`, `hb_IsChar(3)` and `hb_IsDate(Date())`. Rejected like ValType over the same expression: the literals `.T.`, `1.5` and a literal codeblock `{|| 1}` (one named negative each).
- `hb_IsEvalItem` is NOT added. HB_ISEVALITEM is BLOCK|SYMBOL; the oracle gives `hb_IsEvalItem(@Foo())` = .T. and `hb_IsBlock(@Foo())` = .F.,
  so mapping it to `ValType == "B"` would be wrong for symbols. A symbol expression is rejected here (`neg/hb_isblock-symbol.prg`).
- A hash held in a dynamic slot (mixed array element, hash value, call result) is not accepted by the compiler today
  (`neg/dyn-hash-*.prg`). These fixtures pin the rejection; the predicates must be re-measured when such values become reachable. (Dynamic tag 16 is an S4 array tag, not a reachable hash, so it is not a misclassified hash.)
- `hb_Hash(key, value, ...)` with arguments, `hb_IsNumeric`, `hb_IsString`, `hb_IsArray` are unchanged/not added.
- Wine for Windows, not native Windows.

Manifest: t415 was a negative row and is now `pos2` (`return nil`), so the root inventory goes from 1257 to 1258 executable rows
(full total 1314); `EXPECTED_MANIFEST_ROWS` and the runner unit test are updated in the same commit.
