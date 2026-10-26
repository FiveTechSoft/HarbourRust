// t549: hb_HMerge with a non-hash source is a clean compile error.
function main()
    local d := {"a" => 1}
    local s := {1, 2}
    hb_HMerge(d, s)
return nil
