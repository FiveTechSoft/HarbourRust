# Harbour oracle probes (dynamics / hashes / eval order)

Each `.prg` is compiled with `hbmk2 X.prg -gtstd -oX` (Harbour core
694428e1) and run headless with a timeout. `expected.json` holds the byte-exact
stdout of every terminating run as base64 + sha256 (QOut output carries
no trailing LF; raw text files cannot survive editors that append one,
so the exact bytes live ONLY in that JSON). Probes whose Harbour
behaviour is an interactive error dialog HANG headless: they are marked
`hang: true` in the JSON, and the hang itself is the recorded result -
never a compatibility success.

| probe | question | observed (Harbour) |
| --- | --- | --- |
| d1_aadd | AAdd growth | {} grows to 2 elems; a[2]=20 |
| d2_multidim | nested literals | a[1][2]=2; len(a)=2; len(a[2])=2 |
| d3_asize | ASize grow | len becomes 5 |
| d4_hash | hash literal | {"a"=>1,"b"=>2}: h["a"]=1, len=2 |
| d5_hash_set | new key write | h["c"]:=3 grows to len 2 |
| d6_hash_alias | hash assignment | h2:=h ALIASES (h2["a"]:=9 -> h["a"]=9) |
| d7_nested_alias | nested extraction | b:=a[1] aliases inner array (b[1]:=99 -> a[1][1]=99) |
| d8_aadd_alias | array assignment | b:=a aliases; AAdd(b,9) -> len(a)=2 |
| d9_multidim_write | nested write | a[2][1]:=99 works |
| d10_hash_intkey | integer keys | {1=>10}: h[1]=10 |
| d11_hash_missing | missing key read | interactive dialog: HANGS headless |
| d12_hash_keys | key order | hb_HKeys = insertion order ("b","a") |
| e1_asize_nil | grown slots | NIL (prints "NIL"), len 5 |
| e2_asize_shrink | shrink | len 1, a[1] intact |
| e4_len_empty | empty literal | len({})=0; AAdd grows to 1 |
| e5_aadd_ret | AAdd return | returns the ADDED VALUE (5), not the array |
| e6_mixed | mixed types | {1,"texto"} allowed |
| e7_nested_aadd | nested growth | AAdd(a,{1,2}): a[1][2]=2 |
| e9_param_alias | call aliasing | callee AAdd mutates caller's array |
| c12_evalorder | eval order | block expression evaluated BEFORE arguments || c13_cap_param | capture param + escape | works: 15 |
| c14_cap_escape | capture local, outlives function | works: 42 (detached local) |
| c15_cap_loop | loop var capture | ONE shared cell: all blocks print 4 |
| c16_cap_mutate | capture is by reference | n:=99 after creation -> block prints 99 |
| c17_cap_shared | two blocks share the cell | set via one, read via other: 7 |


## Historical hk probes

The 99 numbered hk `.prg` files formerly at the repository root are in
[`legacy-hk/`](legacy-hk/README.md). Their source bytes and filenames are unchanged.
These are separate from the probes and expected.json described above.
