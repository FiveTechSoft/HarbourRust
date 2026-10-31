# Inactive root plus comma group candidate

Not applied. GeneralGroupMatch now distinguishes root captures from per-group
iterations;tested shape FIRST <!a!> [,<!b!>]only. Existing isolated-family guard
remains. Each comma group consumes a literal comma plus one identifier,retaining
the marker's original token/span. Root a is rendered alongside each associated
b iteration. A result group with only a renders once even when b is absent;
a group with only b disappears when b is absent. A repeated b outside an
associated result group cannot match the whole command. No fused capture split.

60existing comma observations pass.72focused a/b-association cases give63token
matches and9differences solely involving semicolon-to-newline preprocessing
representation;no runtime equivalence is inferred for these9. Full268x4original
phase/diagnostics are identical to6ceb09e. No full battery or runtime gate yet.

Before any enablement:fix/respect lexical source identity in mixed root result
contexts;replay80isolated-identifier cases and16guard controls;verify comma-group
runtime and malformed comma negatives;keep nested/multiple pattern groups and
independent optional tails out until represented,not fused. Add body/phase
checks before relying on later diagnostics. Real hbclass VAR has extra tails and
overlapping rules,so this isolated candidate does not unlock classch.

No production source,priorityglobal,classruntime,ABI,memory or main change.
