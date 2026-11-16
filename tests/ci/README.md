# Native CI gates

`native-ci.yml` runs on push and pull_request targeting main, using standard
GitHub-hosted Ubuntu 24.04 and Windows 2022 runners. Jobs are limited to 20
minutes and superseded runs on the same ref are cancelled. The workflow
has only `contents: read`; checkout does not retain its credential. It
uses no repository secrets, Harbour installation, Wine, cache, artifact
upload, release, tag or repository-settings change. No paid/larger runner
is requested. It relies on the public-repository hosted-runner allowance;
if account limits or Actions policy prevent a run, stop and report that
blocker rather than requesting settings or spending changes automatically.

The compiler build uses Rust 1.100.0 and the release recipe:

    rustc --edition=2021 -C opt-level=1 -C debuginfo=0 -C strip=symbols src/hbc.rs -o hbc

Windows outputs hbc.exe. Rustup fetches the pinned toolchain from the
standard distribution; Python and (on Linux) GNU as/ld are supplied by
the hosted runner image. No external assembler is needed on Windows.

## Gates and evidence boundaries

- Both hosts run `tests/ci/compile_pe.py`: all active root-manifest kinds
  are parsed explicitly; unknown/missing/duplicate entries fail. Positive
  cases must emit nonempty PE-target assembly. Negative cases must exit 1
  with the expected diagnostic, never a panic. The CLI case compares raw
  stdout, empty stderr and exit 0. This checks the front end and emission,
  not assembly/linking/execution of the root PE battery.
- At introduction on f70407f1: 1748 manifest entries, 1727 matching checks,
  21 KNOWN-MISMATCH records. `pe-known-mismatches.json` records t110's
  admitted include-angle negative and 20 CurDir/diagnostic-precedence
  mismatches. They are executed, not skipped. Their source SHA256, rc and
  exact diagnostic are pinned. A new discrepancy, changed known outcome,
  or newly passing debt case fails CI until the record is reviewed.
  A successful job does NOT mean 1748 passes or a fully green root battery.
- Linux runs the existing FILE fixture gate without `--hbmk2` or `--wine`:
  23 native execution/rejection checks, internal and GNU assembly routes.
  Its versioned raw fixtures identify the Harbour revision/GTSTD profile
  in tests/file-compat/manifest.json. Filesystem setup includes symlinks;
  this particular runner is not claimed portable to native Windows.
- Windows runs the existing windows-separators gate without `--wine`:
  p_sep, matrix and mixed execute as native PE, internal assembler only,
  comparing raw exit/stdout/stderr to the versioned official Harbour
  GTSTD/Wine captures and their oracle.json provenance. Fixture origin
  remains Wine even when CI executes hbc output on real Windows. See that
  directory's README for the open GTSTD/GTCGI console-profile debt.

Each subprocess has a timeout as well as the job limit. Reports under
work/ci-pe and work/ci-file record compiler/manifest hashes; job logs show
known debt and unexpected compiler diagnostics. The separator runner
prints mismatching raw streams in the job log. No reports are uploaded
or retained through an additional storage service.

Run locally from the repository root (use a NEW output directory):

    python tests/ci/compile_pe.py --compiler ./hbc --output work/local-pe
    python tests/file-compat/check.py --compiler ./hbc --output work/local-file

On Windows, build hbc.exe and run:

    python tests/ci/compile_pe.py --compiler ./hbc.exe --output work/local-pe
    python tests/classes/windows-separators/check.py --compiler ./hbc.exe

The older tests/run_battery_win_compile.ps1 is not used: it ignores
several manifest kinds, skips classes and does not return failure when
its accumulated counters are nonzero. No old workflow is enabled or
changed by this addition. In particular this does not dispatch the
manual macOS feasibility or old approved-patch publisher workflows.

Initial validation: clean Linux build, FILE and compile-only gate tested
locally. Windows-host compiler cross-build/smokes under Wine are distinct
from a native Windows Actions run. The first actual hosted Windows run
remains pending at preparation time; a workflow definition or lint pass
is not evidence that GitHub has executed it successfully.
