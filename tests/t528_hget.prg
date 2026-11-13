// t528: hb_HGet(h, key [, default]) - the value casilla of an existing
// key, with or without the default (hk158a/e); an existing NIL value
// stays NIL and the default is NOT applied (hk158c). A missing key is
// the registered clean bound-error failure mode (t529).
function main()
    local h := {"a" => 1, "bb" => 2, "n" => nil}
    ? hb_HGet(h, "a")
    ? hb_HGet(h, "bb")
    ? hb_HGet(h, "a", 42)
    ? hb_HGet(h, "n")
    ? hb_HGet(h, "n", 42)
return nil
