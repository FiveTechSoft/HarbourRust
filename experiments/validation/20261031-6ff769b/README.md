# Validation evidence for the multiarg piece (2026-10-31)

Commits: 6ff769b (piece) + 72b0c00 (PCount named rejection) + the
HB_SYMBOL_UNUSED builtin revert + traversal batches. Provenance:
fixing-agent direct shell runs in its sandbox on the final committed
source, branch experiment/llvm-scalar-aot. Direct executions, not
OpenCode runs.

- battery-final.log: full battery, ALL GREEN 1367 checks, single
  complete run on the final source (immutable compiler binary).
- llvm-final.log: full LLVM gate on the same final source.
- A PRIOR gate run (/tmp/llvm-multiarg2.log, discarded as evidence) was
  tainted by rebuilding ./hbc mid-run (the PCount rejection edit at
  09:26); the run was killed and repeated cleanly. Cause recorded here
  per the evidence discipline; the tainted log is not preserved as
  proof of anything.

## Acceptance / diagnostics comparison for the repinned tests

Six "uninferable parameter" neg tests flipped to pos (t64, t667, t702,
t881, t914, t944): each verified BYTE-EXACT against the real Harbour
oracle r2610242111 built from source pinned at 694428e1c12f
(`hbmk2 -quiet -gtstd -w0`) before flipping. Precise reason: call-site
literal type evidence was always available; the inferencer did not use
it (only the 63zd float trail existed). Harbour retypes parameters per
call, so a literal-pinned parameter is the correct static reading, not
a semantic change.

- t63_params_arity: repurposed from too-few to too-many arguments.
  Harbour ACCEPTS extra arguments (visible via hb_PValue); HR rejects
  them by name - a registered divergence, not oracle-matchable.
- t1003_recursive_inline_wrongarg: Harbour runs the program and dies
  at RUNTIME ("bad" < 1 type error). HR rejects at compile time; the
  diagnostic moved from the more precise "argument 1" to "never returns
  a value" because the Dyn-merged parameter routes through the covered
  limits stack (mixed iif arms + recursive inline return). The
  precision loss stays OPEN - not closed as parity.
- t1026_default_unused_undef_neg: ORIGINAL preserved unchanged. The
  #undef behavior is real: src/pp.rs predefines HB_SYMBOL_UNUSED as a
  function-like macro ((symbol)) per std.ch:55 (measured hk458) and
  #undef is authoritative, so the statement after #undef names an
  unknown function. multiarg.prg itself uses the macro path (no #undef)
  and was never affected. (An earlier iteration of this piece briefly
  added an unconditional hb_symbol_unused builtin; it was reverted as
  incorrect before any push.)

## hb_PValue real limits (checked, named)

- Covers the DECLARED parameter list only. Extra call arguments are a
  named compile rejection (Harbour accepts them; registered
  divergence).
- PCount(): named rejection t1368 - the calling convention carries no
  argument count. (Harbour oracle answers the actual count.)
- @-received parameters: read through the owner's slot, byte-exact
  (t1364, Linux + Wine).
- The index expression evaluates once; parameters are read from their
  slots (strings are owned tag-4 copies; no call-argument reevaluation
  exists in the model).
- In `main` every index is NIL (no command-line channel in this
  increment; registered absence).
- A FLOAT parameter cannot be exposed: Dyn has no float payload tag
  (t1367) - the representation decision is pending with the user. This
  is multiarg.prg's own remaining blocker; the original now stops
  exclusively at that named frontier.

## multiarg.prg status

Not passed. Compiles through arity, NIL fill, hb_PValue and
HB_SYMBOL_UNUSED (pp macro path), and stops only at:
"hb_PValue in shoutarg would expose parameter #3 as Dyn, but Dyn has
no float payload tag in this increment (the representation decision is
pending)" - identical on Linux and Windows targets.
