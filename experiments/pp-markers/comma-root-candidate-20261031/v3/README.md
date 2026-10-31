# Inactive explicit group instances

Not applied. GroupMatch has root captures,GroupInstance values and consumed
count. Each GroupInstance has pattern group identity,marker identity and its
own GroupIteration values. Independent AS tail is group6,not an extra root
capture;the comma group is group2. Rendering looks up each group independently.
This removes accidental coupling between comma count and optional tail presence.

32tail cases retain27matches/5semicolon-newline differences;80identifier and
16familyguard controls pass. Fresh full268x4original phase/diagnostics identical
to6ceb09e. No full battery or original execution gate claimed for this prototype.

Decision:do not publish an accumulating set of hard-coded pattern lengths.
The executable prototype establishes the data contract,but VAR needs a bounded
pattern plan:Literal,Marker,and OptionalGroup(group_id,children)with marker-owner
mapping. ResultGroup stores owner group set and may repeat over one group while
broadcasting root or singleton sibling captures. Cross-product/multiple repeated
owners and nested association must stay rejected until measured/implemented.

Next minimum production-quality implementation should parse a generic one-level
plan supporting root identifiers,literal-prefixed repeated identifier groups and
independent singleton optional groups. Build once per rule,not source-specific
whitespace splits. Keep pattern/result spans for lexical data,enumerate bounded
match alternatives when a following literal or optional group needs tokens.
The current family guard preserves whole historical overlap families;it is not
correct header coverage. Real VAR with expression/type/flag tails is beyond this
prototype until corresponding node contracts are included. No shortcut to claim
classch works. No runtime/ABI/global priority change.
