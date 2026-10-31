# Plain type tail in isolated reduced VAR

Own MIT code; pinned Harbour is a behavioral oracle, not an implementation source.
The prior five-node topology now also accepts plain `<type>` instead of only
`<!type!>`. Type and initializer expressions keep separate source spans and
iteration owners. Source ordering may differ from result ordering. The same
conservative expression admission and limits apply to both tails, including
operator/anchor handling; no new expression tokens are admitted by this change.

This is still an isolated command family with root identifier, comma identifier
repeats and restricted-anchored type/init tails. Real hbclass VAR has additional
flags, overlapping variants and downstream class behavior, none enabled here.
Global rule selection, rescan and removal are not changed. The prior known
uncommand/xcommand mismatch remains a gap. Three COMMAND temporal controls pass.

6148 own probes:2756tokenmatches(includesunchangedlines),2822explicitrejections,
570unmatchedknown gaps,0false translations observed,not a completeness proof.
Run check_reduced_var.py --corpus plain-type-20261031/cases.json.gz with hbpp/hpp
and output-dir. Prior6134replay categories remain identical,410smart+3explicit
rejections pass,80identifier16family controls pass.16plan units pass.

Six new own runtime programs match Harbour/default/LLVM exact Linux exit and
stdout/stderr. Six positive/two rejection manifest rows added. Full local and independent remote gates:
1267manifest+5aux=1272default PASS lines;566LLVM PASS lines. All268originals x4
compile profiles retain exact prior exit/first diagnostics;21/15Linux20/14Windows.
14reviewed unchanged Linux console originals exact versus freshly built Harbour
in both backends. No original unlock,size/speed,main,runtime/ABI/ownership/debugger
implementation change. Independent remote6148replay/diagnostic audit and full gates verified.
