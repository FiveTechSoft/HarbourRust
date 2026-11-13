// An array of strings does not satisfy a parameter pinned to a flat
// dynamic array by whole-array evidence (len): a genuine type mismatch.
// (Before iteration 29 this file pinned the blanket parameter rejection;
// arrays of strings ARE valid parameters now, moved - see t309.)
function take(k)
    ? len(k)
return 0
function main()
    local h := {=>}
    h["a"] := 1
    ? take(hb_HKeys(h))
return nil
