# Literal WAIT prompt, Linux GTSTD

Own MIT. Parser accepts WAIT with no argument or exactly one literal string.
Ordinary Linux only. This reuses the existing counted GTSTD console writer
and blocking input helper. Prompt gets the same leading LF as bare WAIT.
Printable key echo is unchanged. No dynamic expressions, TO variables,
threads, LLVM, Windows or Mach-O. This is not a terminal-emulator claim.

240 exact stdout/stderr/rc triples:12 prompts,4 printable keys,5 native modes.
Includes empty,spaces,long text,UTF8,CR,BS,LF,TAB,FF and BEL. Escape syntax is
the already admitted ASCII subset; numeric escapes remain rejected.
8 compile limits plus3 unconditional final DELTA=0/rc99 checks.
Bare WAIT regression uses gtstd-render/exits.py and original-input-control.
Control-only input or EOF can keep the external oracle waiting. No completion
claim for those inputs, and no change to Inkey or stdin semantics.

Intact upstream str.prg advances from WAIT prompt parse failure to unsupported
Set(_SET_FIXED,.T.). Census still64/1041 admitted. Five other originals advance
their first diagnostic. No intact-original closure is claimed by this change.
No Harbour implementation code or cambio.diff copied. Black-box oracle:
https://github.com/harbour/core.git commit694428e1c12f726675b19324d62167fa77d68185.

python3 tests/wait-prompt/check.py --compiler /path/hbc --hbmk2 /path/hbmk2 --output /tmp/wait-own
python3 tests/wait-prompt/limits.py --compiler /path/hbc --output /tmp/wait-limits
