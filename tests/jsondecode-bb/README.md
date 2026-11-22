# hb_jsonDecode() - clean-room JSON parser

Coverage: 14 exact oracle rows in jsondecode_bb, plus a 3-row escape oracle file whose second row is divergent under the UTF-8 policy. The escape file as a whole is not an exact-pass claim.

`hb_jsonDecode(text)` parses the JSON text and returns the value as a
Dyn casilla (runtime/hrjson.c, generated/hrjson.s via
tests/generate_json_asm.py; black-box fitted from real Harbour 3.2
outputs - no GPL source read):

- numbers decode exact: integers as tag-0 pairs (9223372036854775807
  included); floats keep the LITERAL's written decimals in the Dyn
  float pair's dec byte, so `hb_jsonEncode(hb_jsonDecode("1.5"))`
  round-trips "1.5" (the oracle prints them with the item decimals).
- strings decode owned with `\" \\ \/ \b \f \n \r \t` reversed; a
  `\uXXXX` codepoint emits as UTF-8 (the standard JSON interchange
  form; the oracle machine's console-codepage mapping for >= 0x80 is an
  environment-dependent divergence, registered).
- `true`/`false`/`null` decode to the logical/NIL tags; a parse failure
  decodes to NIL (the oracle: 'not json' -> U, no error raised).
- arrays decode as tag-8 blocks the ordinary AAdd/Len/indexing
  machinery accepts (count at payload-8; capacity == length).
- a JSON OBJECT is not representable in the hbc Dyn union (its ValType
  has no tag-test by design): the clean runtime type error, a
  registered divergence from Harbour's H.

Admitted argument: a string (borrowed; an owned temporary releases
after the call). The `hb_jsonDecode(x, @var)` two-argument form stays a
named rejection (the oracle's return contract there is unmeasured).

`expected/*.windows.out` is real Harbour 3.2 output (hbmk2
-comp=mingw64 -gtcgi, native Windows 11); the Linux files are the same
bytes with LF line ends. hbc output is byte-identical (14 pins in jsondecode_bb plus 3 in jsondecode_escapes). The 14-row program is registered as an exact root-manifest case. The 3-row escape oracle pin is preserved unchanged but is NOT exact under this runtime UTF-8 policy: the escaped e-acute row now has length 4, while the recorded console-codepage pin has length 3. tests/json-safety/programs/escapes_utf8.prg and its explicitly self-pinned UTF-8 expectations register this divergence, not an oracle pass.
