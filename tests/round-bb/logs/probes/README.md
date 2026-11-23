# Probe execution records (v7)

Each of the four regression probes was compiled with the v7 compiler and
executed; raw stdout, stderr and exit code are recorded per probe
(`<name>.out` / `<name>.err` / `<name>.rc`; every run: rc 0, stderr
empty). These are the same runs `check.sh` pins byte-for-byte.

`leak-prefix-v3.*` is the SAME `round_probes_leak.prg` built with the
pre-fix v3 compiler (commit ae35aee8): `pending 1000` (one `{}` block
per shape per iteration leaks; the owned-Dyn leak was already fixed in
v3). `leak.out` (v7 compiler, same bytes on v4-v6): `pending 0`. On v2 (29a188d6), before
either fix, the two-shape form of this probe showed `pending 1000`
(500 owned-Dyn float cells + 500 owned-Dyn strings) - recorded in the
v3 delivery notes.
