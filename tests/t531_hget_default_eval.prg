// t531: the hb_HGet default is ALWAYS evaluated - its effects fire on a
// present key and on an existing NIL value, before the result
// (hk158f1/f2); the value is discarded (it never rescues or overrides).
function eff()
    ? 7
    return 42
function main()
    local h := {"a" => 1, "n" => nil}
    ? hb_HGet(h, "a", eff())
    ? hb_HGet(h, "n", eff())
return nil
