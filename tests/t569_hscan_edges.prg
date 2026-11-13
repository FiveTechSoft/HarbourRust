// t569: hb_HScan edges (hk179): start 0 scans from the first entry;
// a negative start or one past the last entry finds nothing; start at
// the last position still scans it; an empty hash answers 0; a NIL
// argument never matches stored integers.
function main()
    local h := {"a" => 10, "b" => 20, "c" => 30}
    local e := {=>}
    ? hb_HScan(h, 10, 0)
    ? hb_HScan(h, 10, -1)
    ? hb_HScan(h, 10, 4)
    ? hb_HScan(h, 30, 3)
    ? hb_HScan(e, 10)
    ? hb_HScan(h, NIL)
return nil
