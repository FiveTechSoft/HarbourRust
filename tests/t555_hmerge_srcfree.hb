// t555: hb_HMerge copies are INDEPENDENT of the source - the merged
// entries stay valid after the source hash is freed (the source dies
// at the callee's scope exit; the target travels back by move and is
// read AFTER that free), and nothing leaks (wrap + memcheck = 0, own
// ownership check; not a Harbour oracle).
function feed(d)
    local s := {"a" => 1, "bb" => 2}
    hb_HMerge(d, s)
return d
function wrap()
    local d := {=>}
    d := feed(d)
    ? d["bb"]
    ? len(d)
    return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
