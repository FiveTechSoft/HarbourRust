// t532: hb_HSet(h, key, value) - the functional hash write (hk159):
// append grows len, an existing key is overwritten in place, NIL
// roundtrips; the statement form is the PoC surface (the hash it
// returns is out of scope, registered - ValType H, hk160).
function main()
    local h := {"a" => 1}
    hb_HSet(h, "bb", 2)
    ? len(h)
    ? h["bb"]
    hb_HSet(h, "a", 9)
    ? len(h)
    ? h["a"]
    hb_HSet(h, "n", NIL)
    ? h["n"]
    ? len(h)
return nil
