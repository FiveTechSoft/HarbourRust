// t589: hb_HGetDef(h, key [, default]) - hit returns the value; a
// miss returns the default WITHOUT adding the key, or NIL with no
// default (hk194); the trailing hb_HHasKey checks render .T./.F.
function main()
    local h := {"a" => 1}
    ? hb_HGetDef(h, "a")
    ? hb_HGetDef(h, "x", 9)
    ? len(h)
    ? hb_HGetDef(h, "y")
    ? len(h)
    ? hb_HHasKey(h, "x")
    ? hb_HHasKey(h, "y")
return nil
