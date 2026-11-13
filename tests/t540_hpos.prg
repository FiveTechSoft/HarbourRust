// t540: hb_HPos(h, key) - the 1-based position among the live entries
// in insertion order for present keys, 0 for a missing key and for ""
// (hk162, compiled hbmk2 -gtstd, core libraries only).
function main()
    local h := {"a" => 1, "bb" => 2, "c" => 3}
    ? hb_HPos(h, "a")
    ? hb_HPos(h, "bb")
    ? hb_HPos(h, "c")
    ? hb_HPos(h, "zz")
    ? hb_HPos(h, "")
return nil
