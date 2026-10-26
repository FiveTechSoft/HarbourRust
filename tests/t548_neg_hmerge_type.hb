// t548: hb_HMerge on a non-hash target is a clean compile error.
function main()
    local a := {1, 2}
    local s := {"a" => 1}
    hb_HMerge(a, s)
return nil
