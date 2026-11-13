# Build manifest and force-push record (ains piece 1a, 31Oct)

## Binary-to-source binding (battery of 31Oct ~16:47-16:53 CET)

- Post-hoc reconstructed compiler binary sha256: 76a05dc409a3c88ec70943b69dbd355a5cb136584fed74dfde4e81cd40ed96aa
  (rebuild of the 5085ee94 src tree; the hash was captured at 16:57 CET,
  AFTER the battery run - no binary hash was anchored during the run itself)
- Build command: `rustc -O src/hbc.rs -o hbc` (no other flags, no --edition), rustc 1.99.1 (58cf8f9c3 2026-10-13)
- Source blob (git): src/hbc.rs = a977ed86f3dcda92a736f463335abd77f023381f
- Tests manifest blob: tests/manifest.txt = e8f1ff8b4dc769a5a5b875992e8895044356e39b
- A rebuild from blob a977ed86 with the same toolchain/flags reproduces the
  binary bit-exactly (verified 16:57, same sha256).

## Abandoned vs published snapshot: identity by hash

`git diff a124d582 5085ee94` = 8530 files: 1 insertion (.gitignore) and
only deletions of build artifacts (gen/*, tools/mingw/*, hbc binary).
Every tracked source/test blob is IDENTICAL in both commits, including the
two blobs above. The post-hoc rebuild therefore binds 76a05dc to the
5085ee94 sources by hash. This does NOT prove the 16:53 battery ran that
exact binary: the run-time binary hash was never captured. What is proven
(31Oct 17:29): the hbc binary swept into a124d58 (sha256
06e4cfef7a7f7ec056c89831f0122f15268c3c4623be506f2092af8d6999f846) is a
STALE pre-piece-1a build (bit-exact rebuild of hr-aeval@f3e4e5a's src tree;
it rejects tests/t1422_mixed_dyn_cells.prg with the pre-1a named rejection),
so it cannot be the battery binary, whose green run required piece-1a
codegen. The abandoned binary is classified pre-1a artifact, not battery
evidence.

## Force-push scope record (the a124d58 incident)

- Old branch tip: a124d582 (tree 9f6315cd15a5275ccef92d45742f0e492bc5f94e,
  parent 6e65a2e1e62f82cc2279cc427d46d671d3c0ef20) - contained 6040 gen/
  artifacts committed by an accidental `git add -A`.
- New branch tip: 5085ee94 (tree 0800ca34f0063659e74d5aef4f27ab120734f3a7,
  same parent) - same tracked content minus artifacts, plus .gitignore.
- Remote ops (31Oct ~16:53-16:56 CET): force-push of
  experiment/llvm-scalar-aot a124d582 -> 5085ee94; remote tag
  ains-1a-a124d58 deleted; tag ains-1a-5085ee9 created. No other refs touched.
- Recovery: the a124d582 object is retained in the maintainer clone under
  refs/recovery/a124d58 (never pushed); an incremental bundle on base
  6e65a2e1 exists at /tmp/a124d58-abandoned.inc.bundle (28 MB, mostly the
  gen/ payloads) and can be supplied on request.
- Rule going forward (main, 16:56): never rewrite remote history or delete
  published tags unilaterally; cleanups are normal commits with explicit
  staging and `git diff --cached` review before push.
