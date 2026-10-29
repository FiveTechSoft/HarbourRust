# Harbour source inventory and coverage states

This is metadata about the pinned official reference, not copied Harbour code.
The project's implementation remains its own MIT code. Harbour is an external
behavioural oracle; inventorying a file does not approve running it or linking
its libraries into HarbourRust.

Reference:694428e1c12f726675b19324d62167fa77d68185
Source:https://codeload.github.com/harbour/core/tar.gz/694428e1c12f726675b19324d62167fa77d68185
Tarball SHA256:80ce1e926bf352d4b12d277f06d13df259f9d06322193e1912a6c0c5f1eab355

Inventory:1203 files (1041 .prg,19 .hb,143 .ch). These are NOT1203 examples or
1060 standalone programs. Profiles partition files, not language coverage:
A-tests, B-extras, B-utils, C-contrib, internal-source and support. Headers are
not runnable tests. Entrypoints, runtime dependencies, effects and platform
needs still require review. Includes/main regex fields are review hints only,
not a parser or execution-readiness proof. Never execute arbitrary originals
in bulk based on those hints; isolate file/network/RDD/interactive cases.

The frozen175 compilation evidence is imported with exact file hashes and
compiler SHA f5daec7beb1f63af2b416756c063d5e2330c43b9. Counts20 default /14LLVM
accepted are compilation ONLY. No row is marked executed by this inventory.
not-audited means this manifest has not reconciled an execution result, not
that no separate execution evidence exists in the experimental suite. Prior
original execution checks remain separately recorded in those test logs.

Reproduce inventory from an already obtained reference and exact compile audit:

```
python3 tools/inventory_harbour.py --core /path/to/harbour-core \
  --reference 694428e1c12f726675b19324d62167fa77d68185 \
  --audit corpus/frozen175-f5daec7-compile.json --output /tmp/inventory.json
cmp /tmp/inventory.json corpus/harbour-694428e1-inventory.json
```

Per-file progress must move through independent gates: reviewed entrypoint and
safe fixture; reference compiles/links/runs; each backend compiles/links/runs;
stdout/stderr/exit/effects match or have an explicit divergence; sizes captured;
performance comparable and measured. A compiler acceptance is not a runtime
pass. A blocked dependency is neither a pass nor a failure of the language.

## Roadmap working order

P0 inventory and family matrix; P1 comparable speed/size controls; P2 lexical
and preprocessor gaps; P3 scopes/control/functions; P4 representations/runtime;
P5 blocks/classes/dynamism; P6 library/I/O/RDD/contrib; P7 profile closure.
P1 is a gate on every implementation phase, not postponed until the end.
P0 is in progress: file inventory exists, entrypoint/dependency review and full
syntax-family/test matrix remain. P1 has11 trace-equivalent scalar controls and
3 bounded full-process cross-language cases. No language-wide parity claim.

New representations, memory/aliasing models, macro evaluation and extension
bridges require their own decisions. This roadmap records needs, not authority
to change those contracts or merge the experimental backend into main.
