# Inactive group/iteration identifier prototype

This is a separate,smaller experiment than extended v3. Not applied.
Candidate scope:one [<!x!>]group,one identifier capture,no group literals,
no nested/multiple groups. No runtime,ABI or existing extended matcher changes.

Data:GroupMatch(group_id,iterations,consumed)and
GroupIteration(group_id,ordinal,source span,individual Capture vector).
Result bracket content is rendered separately for each iteration. A repeated
marker outside its associated result group cannot match. This avoids fused
text and preserves original token/source identities.

80existing own-source cases of this exact shape across4directive families and
all previously measured result variants match hbpp. Full268x4original audit
including diagnostics is identical to ea076a3. These gates were run before the
last integration of normal rule specificity/tie selection;rerun them before
relying on the saved patch. The patch is NOT production support.

Next:replace naive bracket/marker detection with staged result parsing that
respects string literals and marker identity;keep existing specificity/tie
selection,validate overlapping rules;run existing positive and rejection grids.
t1239needs an intentional expectation change only after runtime/result review.
No full battery or original execution gate has run for this candidate.

Out of scope:restricted/extended/wildcard groups,literal-bearing or nested
optional groups,multiple-group association and cross-group dependencies.
Unsupported shapes retain historical handling,not a new compatibility claim.
