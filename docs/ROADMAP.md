# Roadmap and current limits

This is an index of agreed work, not a completion percentage or a claim that
an entire Harbour application already runs unchanged. Detailed scope and
evidence live in the linked records. No delivery dates are promised here.

## Ordered milestones

1. **Windows read-only DBF/NTX/CDX adapter.** The bounded adapter is in main.
   Publication of a rebuilt compiler is a separate step; a source commit is
   not proof that every downloadable binary contains it. Keep the existing
   single-area, six-argument, shared=.F./readonly=.T. reader subset, explicit
   index opening and ASCII path contract. No writes, structural CDX autoopen
   or general RDD compatibility is implied. See [Windows adapter scope and
   evidence](DBF-WINDOWS-READONLY.md), [DBF](DBF-READONLY.md),
   [NTX](NTX-READONLY.md) and [CDX](CDX-READONLY.md). Windows execution evidence
   for this adapter is under Wine11, not native Windows certification.

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
- **Default output name:** a separate small CLI increment will allow an omitted
  output argument to derive the executable name from the input stem while
  preserving its case, after the read-only Windows DBF unit. The current
  explicit-output path already preserves the supplied name. Overwriting an
  existing differently-cased Windows filename does not imply that hbc
  lowercases the requested name; filesystem overwrite behavior is unchanged.
- **Platform and backend scope:** [build instructions](../BUILDING.md),
  [host target defaults](HOST-TARGET-DEFAULT.md), [experimental Intel Mach-O
  and ARM64 limits](MACHO-INTEL.md), [classes](CLASSES.md) and
  [threads](THREADS.md). A pass under one backend or Wine is not a claim about
  another backend or native hardware.

## Reading current evidence

Use the [documentation index](README.md), [diagnostic baseline](BASELINE-2026-11-13.md)
and individual increment records. Keep dated measurements dated; the original
ERP issue remains its historical report until a fresh repeat is recorded.
