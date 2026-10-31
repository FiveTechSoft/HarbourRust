# Inactive helper-phase research

No production change. Own black-box probes and own MIT prototype patches.
Baseline is bdc2e00. Call-form translations currently run after commands,so
expanded call results never undergo command matching. Ten probes isolate:
8call-phase cases (factory,source/rescan,stringify,separators,non-command context)
and2non-call identifier-concatenation gaps,which are separate work.

Moving call expansion ahead of commands fixes the8focused forms but reveals
13earlier original pp errors: a generated factory with two definitions uses a
single semicolon boundary,where production recognizes only doubled separators.
It absorbs the second definition's restricted pattern into the first result.
This broad call prototype is not enabled.30013historicalsources show1delta:
WRAP now produces two fully expanded commands,not two unfinished PROBE lines.

Six own factory probes show Harbour accepts single separators before generated
COMMAND/XCOMMAND directives,while keeping ordinary body separators inside the
new rule. A narrow inactive factory patch fixes those probes with only1blank
line delta over30013historicalsources,and0original268x4diagnostic deltas.

Combining factory boundary and call phase removes the13false earlier errors.
11original diagnostic rows change only their emitted-line number,same lexer
unknown-dotted-word error;no accepted count changes21/15Linux20/14Windows.
None of this is gate closure. Full batteries,focused generated-directive quote/
escape controls,temporal mutation/cycles,14original runtime checks and remote
verification remain before activation. Non-call JOIN and identifier adjacency
remain unsupported. Whole hbclass and class runtime are not completed.
