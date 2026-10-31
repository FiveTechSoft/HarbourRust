# Repeated captures and result groups: measured contract, not implemented

280own observations distinguish optional result syntax from match repetition.
This is characterization only, not280compatibility passes.

With [<!x!>] and alpha beta:
- OUT(<(x)>) does not consume a repeated whole command in Harbour.
- OUT([<(x)>]) expands once per matched item:OUT("alpha""beta").
- OUT([<(x)>,]) emitsOUT("alpha","beta",), including the template separator.
- Plain [<x>] repeats too; current concatenated token text is not equivalent.

With <!x!> [,<!y!>], classch-like alpha,beta,gamma preserves the first item
and repeats the result group for y. The current capture representation erases
iteration boundaries and separator spans while appending parts. Counting parts
is only a fail-closed guard for the admitted identifier smart-result slice,
not a general representation of repeated values.

A literal-bearing optional group [KEY <!x!> VALUE <y>] can also currently consume
too much into its final plain capture. The measured repeated sentence is left
unchanged by Harbour in the tested forms but translated by both the historical
and current engine. This is a pre-existing matching gap,not fixed by smart
stringify. previous-comparison.json preserves all three outcomes.

A correct next representation must retain each pattern group's identity, its
per-iteration captures, original token/source spans, and the association between
a repeated result group and its controlling captures. Matching eligibility and
result expansion are coupled: merely splitting a fused capture into words is
wrong for nested delimiters,quoted strings,paired markers and skipped optionals.
It also needs an explicit bound on iterations and expansion size,plus first-
diagnostic comparison across the original corpus. No runtime,ABI or class
implementation is implied. No repeated matcher change is included here.
