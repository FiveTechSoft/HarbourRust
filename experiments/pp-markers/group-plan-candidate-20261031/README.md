# Inactive bounded group plan module

Own standalone Rust module,not imported by pp.rs and not a support claim.
Nodes:Literal,Identifier(marker ID),Optional(group ID,atoms). Marker table maps
name to root/group owner. Matching returns root token spans and per-group,
per-iteration token/capture spans. Bounded greedy alternatives leave following
literals available by backtracking,without fused token reconstruction.

Result association selects at most one repeated owner as driver;root captures
and singleton sibling groups broadcast. A group with a bound root but missing
optional sibling renders once;an entirely unbound result group disappears.
More than one repeated owner and ungrouped repeated output explicitly error in
this prototype. No Cartesian product or silent zip of independent groups.

Eight local unit checks pass for comma+tail identity,required-tail backtracking,
malformed commas,prefix consumption,nested/duplicate rejection,result broadcast,
unbound siblings and multiple repeated-owner rejection. These are data-contract
unit checks,not Harbour equivalence or runtime tests. The module has NOT been
integrated with the existing renderer,definition/removal storage or family guard.
No original diagnostic gate was needed for this unreferenced module;production
source is unchanged. Next integrate only in temporary copy,using the existing
60/72/32observations and80/16regressions before any enablement.

Scope stays identifiers and one-level optional literal groups. Restricted/plain
expression markers and nested groups are absent,so this is not real hbclass VAR
support. Repetition cardinality is still a match/result contract to validate:
greedy alternatives alone do not certify Harbour matching. Required rescan/rule
identity behavior remains separate from latest-rule priority. No ABI/runtime,
main,class implementation,debugger or performance change.
