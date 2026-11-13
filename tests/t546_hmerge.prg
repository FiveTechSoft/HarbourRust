// t546: hb_HMerge(dst, src) - the source WINS on an overlapping key
// and keeps its position; new keys append at the end in source order
// (hk164, compiled hbmk2 -gtstd, core libraries only).
function main()
    local d := {"a" => 1, "bb" => 2}
    local s := {"bb" => 22, "c" => 3}
    hb_HMerge(d, s)
    ? len(d)
    ? d["a"]
    ? d["bb"]
    ? d["c"]
    ? hb_HPos(d, "bb")
    ? hb_HPos(d, "c")
return nil
