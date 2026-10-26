// t550: hb_HClone(h) - the copy is fully INDEPENDENT in both
// directions (hk166, compiled hbmk2 -gtstd, core libraries only):
// overwriting and adding in the original do not cross into the clone,
// and mutating the clone does not cross into the original.
function main()
    local h := {"a" => 1, "bb" => 2}
    local c := hb_HClone(h)
    h["a"] := 9
    h["c"] := 3
    ? c["a"]
    ? len(c)
    c["bb"] := 22
    ? h["bb"]
    ? len(h)
return nil
