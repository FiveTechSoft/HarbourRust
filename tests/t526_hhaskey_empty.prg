// t526: hb_HHasKey on the empty hash is 0 (hk157's last line); a
// borrowed string variable works as the lookup key.
function main()
    local h := {=>}
    local k := "a"
    ? hb_HHasKey(h, "a")
    h["a"] := 7
    ? hb_HHasKey(h, k)
return nil
