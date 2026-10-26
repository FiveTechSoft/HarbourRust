// t591: hb_HGetDef with the default coming from a Dyn cell (an array
// element carrying a tagged integer) - same int-default family (hk194).
function main()
    local h := {"a" => 1}
    local a := {7}
    ? hb_HGetDef(h, "zz", a[1])
    ? hb_HGetDef(h, "a", a[1])
    ? len(h)
return nil
