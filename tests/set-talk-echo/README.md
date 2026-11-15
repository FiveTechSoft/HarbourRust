# SET TALK/ECHO console-only admission

Exactly SET TALK ON/OFF and SET ECHO ON/OFF are accepted, case-insensitive,
without generated runtime state in console-only programs. Other SET commands
retain their previous rejection. Alternate operands and trailing tokens reject.

check.py compiles two fixtures against Harbour 694428e with gtstd, then compares
exact Linux stdout, stderr and status against native hbc with and without
instrumentation. Optional --wine repeats hbc PE against the same LF bytes
of the existing QOut target contract, not a Windows Harbour oracle. The fixtures
cover all four commands, mixed case, nested blocks, user functions and ProcLine.
Ten negative fixtures test strict syntax, unrelated SET and DBF calls in both
main and a later function. No DBF file is opened by these rejection tests.

Limits: this is only console behavior without detected DBF operations. The
compiler's existing DBF_USED flag rejects combinations even if unreachable or
only TALK OFF/ECHO is used. TALK ON operation feedback must be implemented
when integrating a complete RDD layer. This is not full SET state, Set() query
support, script echo, macro execution or DBF command support.
