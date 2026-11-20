# Signed integer literal hash keys, bounded Linux increment

Own MIT implementation and synthetic tests. Harbour is an external executable oracle only. No external patch is used. P08 is optional unchanged external input.

Ordinary Linux without threads or macro context accepts signed-i64 literals in indexed hash writes, indexed hash reads and hb_HHasKey. Existing numeric, logical, NIL and admitted string values retain their ownership rules. Hash literals with numeric keys, numeric variables, computed keys, F64/Dyn keys and other numeric-key builtins remain rejected. Existing parser syntax can express i64::MIN as a 64-bit binary literal; decimal -9223372036854775808 still hits its pre-existing positive-token range limit. No parser change is claimed.

The new key has a private kind bit distinct from every user string and an immutable 16-byte full-width integer encoding. No decimal/floating conversion can merge neighbors above 2^53. The kind bit travels in the key-length word, while allocation and byte loops use only the physical length. Clone/copy/merge/delete-by-position/clear/fill preserve the key kind and existing key ownership. The rodata lookup view is never freed; hput owns a separate key copy. There is no scratch buffer that a later nested call can overwrite.

hb_HKeys and hb_HKeyAt still have string-only result ABIs. Programs that combine the new key kind with either API are rejected before code emission, including uncalled functions and either source order. The numeric key must never be exposed as its private byte encoding. hb_HSetCaseMatch is also excluded in a new integer-key program: the old compiler requires numeric flags while the external oracle requires logical flags. This increment does not widen or claim to repair that independent API. The runtime comparison still treats the integer kind as byte-exact independent of case folding. These are whole-program conservative limits, not per-hash flow inference.

Run:

    python3 tests/hash-i64-literal/check.py --compiler ./hbc --baseline /previous/hbc --hbmk2 /external/hbmk2 --output /new/exact --external-p08 /original/p08.prg
    python3 tests/hash-i64-literal/safety.py --compiler ./hbc --output /new/safety
    python3 tests/hash-i64-literal/mutants.py --compiler ./hbc --rustc /rustc --hbmk2 /external/hbmk2 --output /new/mutants

The exact gate has 15 own sources plus optional original P08, each compared without normalization in rc/stdout/stderr for internal and external assemblers against fresh Harbour. Safety has 3 instrumented modes, 1000 repeated growth/clone/copy/merge/overwrite/fill/clear loops, forced string-cache reuse, exact distinct >2^53 values, 1000 catches and warmup followed by allocation delta zero. Five profile, 15 shape and 3 uncalled-function rejection controls are separate from oracle claims. Four Rust-build-valid mutants check admission, key-kind separation, integer precision and enumeration's fail-closed limit. Compiler build failures and timeouts do not count as a caught mutant.
