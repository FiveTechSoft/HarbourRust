# Logical hash CaseMatch API and clear-preserve

Own MIT code and probes, external Harbour executable oracle only. Ordinary Linux without threads or macro context uses logical values for hb_HCaseMatch(h), admits hb_HCaseMatch(h, logicalFlag), and admits a logical flag in the existing statement hb_HSetCaseMatch. Query+set returns the OLD flag, after evaluating its flag expression. A hash consumed while evaluating the flag is rejected. Other profiles keep their previously measured numeric getter/one-argument contract; this is not a portable API completion.

hb_HClear in that same profile now preserves the flag, including an empty flagged hash. It frees the existing key/value owners through the old clear helper and restores a false flag through the existing header-only allocator. It does not retain cleared entries. Hash growth and clone continue to preserve the existing header. Numeric key kind is still separate from strings. P08's conservative combination limits with HKeys/HKeyAt/HSetCaseMatch remain; hb_HCaseMatch(h, logicalFlag) itself works with numeric literal keys. Numeric flags passed to hb_HCaseMatch are rejected, not silently coerced. Legacy numeric flags passed to hb_HSetCaseMatch remain accepted for earlier measured programs, not a Harbour-parity claim.

Four untouched root fixtures intentionally expected the former dialect: t556, t560, t563 and t584. The new logical getter changes 1/0 to .T./.F. in all four. t584 additionally observes that clear preserves false and the subsequent case-insensitive lookup succeeds. The original expected files are not edited. The raw full root result is 1259/1263, with exactly those four named differences, rather than an all-pass claim. Original fixtures use numeric setter flags that Harbour rejects; do not claim byte-exact original Harbour runs. Fresh own logical-flag sources independently verify the corrected behavior.

Run:

    python3 tests/hash-logical-case/check.py --compiler ./hbc --baseline /previous/hbc --hbmk2 /external/hbmk2 --output /new/exact
    python3 tests/hash-logical-case/safety.py --compiler ./hbc --output /new/safety
    python3 tests/hash-logical-case/mutants.py --compiler ./hbc --rustc /rustc --hbmk2 /external/hbmk2 --output /new/mutants

17 own sources x internal/external assembler, exact rc/stdout/stderr against fresh Harbour. Three instrumented modes x1000loops cover logical set/query, clone, owned string overwrite, clear preserving mode, nested flags and1000caught flag RHS failures, warmup then allocation delta zero. Five profile and seven shape rejection controls are separate from oracle claims. Three Rust-build-valid counterfactuals detect numeric rendering, returning the new rather than old flag, and resetting mode on clear. An initial checker-only getter mutation survived because expression emission still independently typed Bool; the valid final mutant changes expression typing and is caught by runtime output. The surviving attempt is not counted as a successful mutation test.

No Bin/Cmp implementation/emission, statement/error trace emission, PROC metadata, workflow, manifest or expected fixture is changed. The external C4 sample still needs object DATA hash and other dependencies; this API increment does not claim to unlock it.
