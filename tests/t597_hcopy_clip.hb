// t597: hb_HCopy - count 0 no-op, count past the end clips at len
// (hk195c).
function main()
    local h := {"a" => 1, "b" => 2, "c" => 3}
    local d := {=>}
    hb_HCopy(h, d, 1, 0)
    ? len(d)
    hb_HCopy(h, d, 2, 99)
    ? len(d)
    ? hb_HKeyAt(d, 1)
return nil
