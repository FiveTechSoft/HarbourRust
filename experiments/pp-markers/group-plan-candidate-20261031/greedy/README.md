# Inactive precompiled greedy plan correction

This supersedes the candidate's backtracking assumption,not production source.
The original unit claiming that a repeated bare identifier optional group should
reserve a following END literal was WRONG. Harbour leaves
PROBE alpha beta END done unchanged for PROBE [<!x!>] END <!y!>even with grouped
result output. The bridge previously accepted and translated it falsely.
The unit is replaced by a rejection control;greedy consumption closes that false
accept. Do not propagate the earlier backtracking design as a valid contract.

Plan now stored per Cmd at definition time in temporary copy;removal retains
normal rule storage.80identifier/16family controls pass;164comma/tail retain
150token matches/14semicolon-newline differences. Eight data tests pass. Fresh
268x4original diagnostics remain fully identical to6ceb09e. No full runtime or
battery gate for this candidate. Plan and pp patch are both INACTIVE.

The10owner cases preserve the PREVIOUS bridge outputs,including the false
accept at case9,so the provenance of the correction remains visible. Case5
shows two repeated sibling owners require paired association in Harbour;the
candidate returns an explicit unsupported error,not a cross-product. That shape
must remain outside enabled scope until correct ownership/cardinality support.

Next:limit admitted plan shape to supported cardinalities before production;
validate declaration/result references before rendering errors can displace a
better rule. No header original is unlocked while family overlap guard and
restricted/plain/flag tail exclusions stand. Correctness takes priority over
activating more generic syntax. No global priority,classruntime,ABI or main.
