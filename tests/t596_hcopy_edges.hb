// t596: hb_HCopy edges - start > len and count 0 are no-ops (hk195b;
// the oracle's self-copy line is a named compile-time rejection here,
// covered by t598).
function main()
    local h := {"a" => 1, "b" => 2}
    local d := {=>}
    hb_HCopy(h, d, 5)
    ? len(d)
    hb_HCopy(h, d, 1, 0)
    ? len(d)
return nil
