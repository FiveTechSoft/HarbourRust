# P2 marker gaps: own-source observations

45 preprocessor-only probes compare pinned Harbour hbpp with our standalone
hpp built from41a92c1. These are NOT runtime tests or newly supported features.
No Harbour implementation was read/copied/translated. Every probe is our own.

- `<!x!>` matches a single ASCII identifier in these measurements: Alpha,A_2,_x.
  It does not match a number,quoted string,expression,member/index access,
  multiple tokens,empty input or non-ASCII identifier in this sample.
- Terminal `<*x*>` captures arbitrary nonempty rest-of-line in this sample,
  including comma-separated tokens and invalid expressions. It is lexical,
  not evidence the resulting program parses or runs.
- `<*x*>` followed by STOP matched none of the15 measured inputs. Do not
  implement it as a normal expression capture with a terminator.
- Our current shared preprocessor rejects both marker definitions as E0010.
  The diagnostic's Harbour attribution is wrong for these valid marker forms.
  This publication records the gap; it changes no production source.

These missing marker definitions are the FIRST blocker for23/8 original test
sources in the268 compile audit. Solving them would not make those sources
pass: later class/runtime/library blockers are unknown until re-audited.

Reproduce after building src/hpp.rs with rustc:

```
python3 experiments/pp-markers/probe.py --hbpp /path/to/hbpp \
  --hpp /path/to/hpp --output-dir /tmp/pp-marker-probes
```

The opt-in probe deliberately checks the CURRENT rejection boundary. Update it
only with a separately reviewed implementation and fresh behavior evidence.
