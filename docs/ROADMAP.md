# Roadmap and current limits

This is an index of agreed work, not a completion percentage or a claim that
an entire Harbour application already runs unchanged. Detailed scope and
evidence live in the linked records. No delivery dates are promised here.

## Published source checkpoint: 2026-11-16

Checked against main `5cdc4d50dbef708802b4611e65569362ea334b8b`.
"Published" here means source in main, not that every downloadable compiler
or release asset has been rebuilt. Tests under Wine, external GAS, the
internal executable writers and native hardware are distinct evidence.

| Unit in main | Commit | Admitted scope and remaining limits |
| --- | --- | --- |
| MEMVAR ownership bridge B1 | `89b6389a` | Context-owned storage and compiler export; isolated bridge, not frontend completeness. [B1 record](MEMVAR-OWNERSHIP-BRIDGE-B1-2026-11-15.md). |
| Scoped MEMVAR/evaluator integration B2 | `6f3927f` | PRIVATE/PUBLIC scope, inherited bindings, supported strings/floats and staged parse/fold/runtime. No field context, non-ASCII names or recoverable raise. [B2 record](MEMVAR-MACRO-B2-2026-11-15.md). |
| PE fixed-base policy | `6e18360` | Disables ASLR flags when no relocation directory is emitted, preserves NX. Not general relocation support. [PE record](PE-FIXED-IMAGEBASE-2026-11-15.md). |
| Windows QOut newline | `189ded9` | CRLF for QOut newlines only, not every output operation. |
| Evaluator/native-Windows corrections | `4d22971` | Shared evaluator semantics and Windows crash correction; [runtime record](MACRO-M1-RUNTIME-2026-11-15.md). |
| Native Windows battery row support | `d0b102a` | Runner accepts posx2/streams2. Runner support alone is not proof that every row passes. |
| M2 first builtin dispatch unit | `5cdc4d50` | Upper/Lower/Round through owned argument cells and production helpers. ASCII case, maximum 64 arguments, truncated Round decimals -15..15, terminal-only errors. Other names remain explicit limits. [M2 record](MACRO-M2-2026-11-16.md). |
| Windows read-only DBF/NTX/CDX | `a1812d5` | Bounded reader in main, not a write-capable RDD. [Windows reader record](DBF-WINDOWS-READONLY.md). |
| Omitted output argument | `a278b69` | Derives a case-preserving executable name from the input stem; .exe on the Windows target. Explicit output names are preserved too. |

The B1/B2 records retain dated package-stage wording and measurements. Their
reachable main commits above establish source publication; their limits and
test descriptions still matter. M2's full 1743-row comparison on each target
had zero raw BASE regressions, not a blanket raw-green manifest: inherited
fixture mismatches and 12 compile-blocked PE positives remain documented in
its record. No project-completion percentage follows from those counts.

## Immediate macro sequence

1. **Extend the builtin catalog on the M2 dispatcher.** The first trio is in
   main; it is not the whole catalog. Select the next bounded unit from
   measured coverage and dependencies, then repeat oracle, ownership, error
   ordering, ABI, limits and regression review before publication. No fixed
   order for the remaining individual builtins is promised here.
2. **Field-context semantics (M3)** remain separate: field lookup/precedence,
   aliases and workarea lifetime need an explicit design and evidence. The
   scoped MEMVAR context alone does not implement them.
3. **Later macro forms (M4)** include assignments and array/hash/codeblock
   literals. User-code calls, recoverable ErrorBlock/BREAK/RECOVER and thread
   context propagation are not unlocked by the scalar builtin dispatcher.
   Their scope and order need separate measured units, not an implied grant
   of general macro compatibility.

This records the macro lane without replacing the application/DBF goals
below or claiming that their independent work has been completed.

## Application and DBF milestones

1. **Windows read-only DBF/NTX/CDX adapter: source published, bounded.** Keep
   the single-area, six-argument shared=.F./readonly=.T. reader subset,
   explicit index opening and ASCII path contract. No writes, structural
   CDX autoopen or general RDD compatibility is implied. See [Windows adapter
   scope and evidence](DBF-WINDOWS-READONLY.md), [DBF](DBF-READONLY.md),
   [NTX](NTX-READONLY.md) and [CDX](CDX-READONLY.md). Adapter execution evidence
   is under Wine11, not native Windows certification. This does not establish
   that a customer's DBF or a full tstseek/USE NEW SHARED program works.

2. **Repeat the ERP coverage battery with the current compiler.** Re-run the
   probe kit from the still-open [Windows ERP coverage issue #1](https://github.com/FiveTechSoft/HarbourRust/issues/1)
   and retain the exact compiler version/hash, toolchain, original probe
   sources, stdout/stderr/exit status and real Harbour oracle for each case.
   Reconcile results with the issue's historical baseline, distinguishing
   exact matches, mismatches, explicit unsupported cases and runtime failures.
   The original issue measured an older compiler on native Windows11; a new
   Wine run must be labelled separately and cannot replace that platform
   evidence silently. Do not mark the issue resolved just because individual
   functions or the DBF adapter have landed. The generic probe kit, not private
   ERP source, is the intended first input; recovering the original kit and
   agreeing the repeat environment are prerequisites to a full-battery claim.

3. **DBF writes, index updates and locking.** A separate design and measured
   increment after the read-only work and coverage repeat. Define the admitted
   write/index operations, consistency and error recovery, and shared/record
   locking semantics before enabling them. The existing read-only snapshot
   adapter is not a write-capable RDD or a locking implementation. See the
   current exclusions in [DBF](DBF-READONLY.md), [NTX](NTX-READONLY.md) and
   [CDX](CDX-READONLY.md). No general writes or locking support is claimed now.

4. **Compile and run a real Harbour application on Windows without rewriting
   its code.** This is the application-level goal, not a capability already
   established by small probes or hand-ported routines. Select a concrete
   application with permission to test it, record its unmodified source and
   dependencies, and compare actual behavior with real Harbour on Windows.
   Missing language, library, RDD, GUI or C-extension dependencies remain
   explicit blockers rather than reasons to silently rewrite the application
   into a smaller subset. Completion requires application execution evidence,
   not compilation alone. This goal does not promise general compatibility
   with every Harbour/FiveWin application.

## Other recorded work and boundaries

- **Embedded C in PRG files:** `#pragma BEGINDUMP` ... `#pragma ENDDUMP` is
  currently recognised and rejected explicitly because hbc has no C stage.
  The recorded future goal is real embedded-C support through a C toolchain
  path, such as hbmk2: extract each block into a separate C unit, compile it
  and link through the existing C bridge. This is relevant to Harbour contrib
  and FiveWin-style code. Recognising the pragma without compiling its C is
  not full support. It is not implemented by this roadmap entry and is not
  inserted ahead of the ordered milestones above. See [C Extend bridge,
  named limits](EXTEND-BRIDGE.md#not-in-milestone-1-named-limits) and the
  [current hbmk2 adapter](HBMK2-ADAPTER.md), whose own limits still apply.
- **hbmk2:** the [bounded external adapter](HBMK2-ADAPTER.md) exists for Linux
  x86-64, one Harbour module, and optional supported C/object inputs. Official
  hbmk2 remains an external tool. This is not a Windows adapter or a port of
  the whole hbmk2 interface; existing .hbp/.hbc projects, plugins/resources,
  general libraries and multi-PRG linking are not made compatible by it.
- **Native ARM64:** not implemented. It needs an actual instruction backend
  and a suitable loader/signing path, not a changed CPU header. Experimental
  Intel Mach-O or Rosetta execution is not native ARM64. See [platform
  evidence and limits](MACHO-INTEL.md).
- **Platform and backend scope:** [build instructions](../BUILDING.md),
  [host target defaults](HOST-TARGET-DEFAULT.md), [experimental Intel Mach-O
  and ARM64 limits](MACHO-INTEL.md), [classes](CLASSES.md) and
  [threads](THREADS.md). A pass under one backend or Wine is not a claim about
  another backend or native hardware.

## Reading current evidence

Use the [documentation index](README.md), [diagnostic baseline](BASELINE-2026-11-13.md)
and individual increment records. Keep dated measurements dated; the original
ERP issue remains its historical report until a fresh repeat is recorded.
