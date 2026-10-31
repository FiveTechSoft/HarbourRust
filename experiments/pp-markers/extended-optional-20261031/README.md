# Optional capture/result association observations

220own black-box observations, not supported examples. Both sets were rebuilt
and their exact pinned hbpp outputs checked with replay_reference_observations.py.
The132case set also records inactive v3candidate output;match presence equality
alone is NOT translation equivalence. The88case set varies result groups.

The same optional pattern can match a repeated source with a repeated result
group but not match when the result uses the marker only once:

    #translate PROBE [<(x)>] => HIT(<x>)
    PROBE alpha beta
    // unchanged in Harbour

    #translate PROBE [<(x)>] => HIT([(<x>)])
    PROBE alpha beta
    // HIT((alpha)(beta)) in Harbour

[<(x)> <y>]groups pair values per iteration. KEY-prefixed groups can leave
an unconsumed suffix while repeating the result for each matched KEY clause.
These are matching/result association contracts, not a universal optional
prefix rule. A blanket full-input gate would reject valid measured cases.
A flat fused capture cannot preserve the observed per-iteration mapping.

Needed design data before a general implementation:pattern group identity,
per-iteration marker/source spans,iteration boundaries and result group
association. Preserve source delimiters and consumed suffix boundaries without
retokenizing fused text. No runtime/ownership/ABI change follows from this data.

Production remains ea076a3. Candidate v3is inactive and not certified. Main,
debugger implementation,performance and size are untouched.
