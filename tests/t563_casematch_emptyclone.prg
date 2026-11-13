// t563: an EMPTY hash with the flag set clones to an empty hash that
// still has the flag (header-only block) and matches case-insensitively
// after an insert (oracle hk176).
function main()
    local h := {=>}
    hb_HSetCaseMatch(h, 0)
    local c := hb_HClone(h)
    ? hb_HCaseMatch(c)
    c["A"] := 7
    ? hb_HHasKey(c, "a")
return nil
