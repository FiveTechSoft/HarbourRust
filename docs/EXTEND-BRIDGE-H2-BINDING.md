# H2.0 binding mechanism decision (blocks Windows)

Status: decision note for review, 2026-11-13. No code committed to
either mechanism beyond what milestone 1 already ships. This note
decides how an `EXTERNAL NAME` call finds its C function before
milestone 2.6 (Windows) commits code to one.

## Where we are

Milestone 1 (Linux): `HB_FUNC(NAME)` places a `{name, fn}` entry in
the `hbhbr_funcs` linker section; the hbc thunk `hbc_fn_<name>` calls
`hbc_ext_dispatch`, which walks the section between the GNU-ld
automatic bounds `__start_hbhbr_funcs`/`__stop_hbhbr_funcs` and
matches the name case-insensitively. Verified working through plain
`ld`, the gcc driver, and external hbmk2.

PE/COFF has no `__start_`/`__stop_` bounds, so the section walk does
not port. The decision is what replaces it, and whether Linux moves to
the same mechanism.

## Options

### A. Section walk per target (status quo + a PE variant)

Keep the ELF walk; on PE group the entries with the ordered-section
idiom (`hbhbr$a` entries, `hbhbr$z` terminator - the CRT initializer
trick; MinGW ld supports it, MSVC links `$` subsections in order).

- (+) No change on Linux; HB_FUNC stays a pure compile-time construct.
- (-) Two binding mechanisms to specify, test and debug forever.
- (-) A missing C function is a RUNTIME error ("C function not
  found"), where Harbour and every normal linker workflow fail at
  LINK time. Worse failure mode, later.
- (-) MSVC support for ordered sections is real but obscure; MinGW and
  MSVC would each need their own probe battery.

### B. Direct symbol binding (recommended)

`HB_FUNC(NAME)` names the C function itself `HBHBR_FN_<NAME>`
(uppercase; Harbour already requires uppercase HB_FUNC names by
convention) and the hbc thunk calls that symbol directly. The bridge
globals (`hbc_ext_argc/argv/ret_*`) are unchanged; `hbc_ext_dispatch`
and the section disappear from the call path.

- (+) One mechanism on ELF and PE; no section tricks anywhere.
- (+) A missing C function is a standard LINK error naming
  `HBHBR_FN_<NAME>` - earlier, clearer, and exactly Harbour's own
  failure mode (hbmk2 reports unresolved `HB_FUNC_X`).
- (+) No per-call name compare; the thunk is a jump.
- (+) Works identically through ld, the gcc driver and hbmk2; no
  relocation or decoration surprises on x86-64 (no leading-underscore
  mangling on ELF or PE64).
- (-) Name matching becomes case-sensitive at the C symbol level. The
  .prg side stays case-insensitive: hbc uppercases the EXTERNAL name
  when it forms the symbol, matching the HB_FUNC uppercase convention.
  An extension with a lowercase `HB_FUNC(myFunc)` stops binding - a
  compile-visible break we document (Harbour's headers force uppercase
  too via the same convention).
- (-) Two C objects defining the same HB_FUNC now collide at link
  (duplicate symbol) instead of silently picking the first section
  entry. This is a behavior improvement (Harbour errors too), listed
  for completeness.

### C. Hybrid: direct binding, section walk as fallback

Thunk calls `HBHBR_FN_<NAME>` when linked, else the walk answers "not
found". In practice there is no "else" the user can act on - the link
fails first unless the weak-symbol trick is used, which reintroduces
per-target linker knowledge. Rejected: the fallback only hides
configuration errors.

### D. Generated registry (post-link registration tool)

A tool scans extension objects and emits a table. Rejected: it breaks
the milestone-1 flow (any standard C compiler + the system linker, or
hbmk2 unmodified) and adds a build step Harbour does not have.

## Recommendation

**Option B, on both targets, with a one-line compatibility shim.**
`HB_FUNC` emits the function as `HBHBR_FN_<NAME>` AND keeps a section
entry pointing to it (zero runtime cost, macro-only change). hbc emits
thunks that call the symbol directly. Milestone-1 extension objects
(section-only) keep working through the surviving `hbc_ext_dispatch`
until 2.6 ships; new objects bind directly. Windows (2.6) then needs
no new binding machinery at all - the remaining Windows work is the
runtime helpers and the printer, not the bridge.

## What this decision unblocks

- 2.6 Windows: no PE section research needed.
- The `.prg` `EXTERNAL` surface and the C `hbhbr.h` contract stay
  byte-identical for extension authors.
