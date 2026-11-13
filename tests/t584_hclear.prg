// t584: hb_HClear empties the hash, the hash is reusable, matching
// is case-SENSITIVE again after a clear (the flag resets to the
// default), and clearing an empty hash is a no-op (hk191/hk193).
function main()
    local h := {"a" => 1, "b" => 2}
    local e := {=>}
    hb_HSetCaseMatch(h, 0)
    hb_HClear(h)
    ? len(h)
    h["x"] := 9
    ? len(h)
    ? h["x"]
    ? hb_HCaseMatch(h)
    ? hb_HHasKey(h, "X")
    hb_HClear(e)
    ? len(e)
return nil
