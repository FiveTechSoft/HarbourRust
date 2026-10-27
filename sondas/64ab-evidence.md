# 64ab parenthesized comma expressions

Matched probes hk433,hk435,hk436,hk438,hk440,hk441,hk442 use compiled
Harbour -gtstd byte comparisons. hk432 keeps string/Dyn operands and is
accepted by Harbour but rejected by this numeric/logical-only increment.
hk434 conflicts with existing integer/float parameter pinning; hk437 has
an uninferred return-only parameter; hk439 incorrectly expects Len alone
to pin a string (it currently pins an array). They are preserved failures,
not matches. Distinct probes isolate supported behavior without changing
failed sources or claiming full compatibility.

First hk435 candidate had wrong numeric field provenance for final large
literal. Fixed: fold_int observes only final-value provenance, not effects;
codegen ALWAYS emits every earlier list item. First hk442 candidate missed
a nested block label; block collection now recurses through block bodies.
