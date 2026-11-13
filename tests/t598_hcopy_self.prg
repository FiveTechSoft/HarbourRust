// t598: hb_HCopy(h, h) - Harbour's self-copy runtime error family
// (hk195b) is a named compile-time rejection in this dialect.
function main()
    local h := {"a" => 1}
    hb_HCopy(h, h)
return nil
