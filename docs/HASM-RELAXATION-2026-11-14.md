# Safe lower-bound filtering for branch-layout search

The internal assembler keeps its existing branch relaxation and local
shortening search. It now avoids trials proved unable to retain a short
branch. The optimization changes no instructions, relocation rules, PE
stack settings or imports.

A prefix table sums lower bounds on text-item sizes. Alignment contributes
zero, numeric-only fixed instructions contribute their exact size, raw
bytes and patches contribute their fixed size, and unknown instructions
contribute one byte. If the minimum forward displacement exceeds 127, or
the minimum backward distance exceeds 128 including the short instruction,
the candidate cannot remain short in any possible layout.

The filter only handles exact same-text labels (including numeric labels).
Expressions, constants masquerading as labels, other sections and unknown
forms keep the original search. A global gate disables filtering when a
non-branch instruction length can depend on text addresses. Constant
expressions and RIP-relative displacements have fixed encoding sizes.
This gate ensures that when an impossible candidate grows back to near,
any additional near branches grown during the trial cannot make the text
smaller: fixed sizes plus alignment/maxskip layout are monotone.

The original search still runs on every unproved candidate, with the same
order and acceptance rule. This is not the unsafe diagnostic experiment
that removed local search. That experiment is not included.

Validation covers rel8 forward/backward boundaries, zero lower bounds for
alignment, numeric labels, expression/constant/section fallbacks, and the
global address-dependent-size fallback. Run the paired-output checks with:

```sh
python3 tests/hasm-relaxation/check.py --repo . --output /tmp/hasm-review
```

The checker reads the pinned pre-optimization assembler from git 710a3cb,
builds isolated copies, and compares deterministic alignment/control-flow
fixtures for ELF and PE. Only PE timestamp and its checksum are normalized.
The detailed review records measured timings and the execution evidence.

Branch padding (`docs/HASM-BRANCH-ALIGN-2026-11-21.md`, 21 November)
only adds bytes before jumps, so these lower bounds still hold. The
paired-output check runs with `HASM_BRANCH_ALIGN=0`, since its baseline
predates padding.

Limits: this is a conservative filter, not a new optimal-layout algorithm
or a guarantee of linear-time assembly. Some far branches remain unproved;
symbolic instruction-size inputs retain the old cost. Compilation timing
is not runtime performance, a historical regression measurement, or native
Windows/macOS verification. Existing finite stack reserves and unsupported
SEH/unwind boundaries remain unchanged.
