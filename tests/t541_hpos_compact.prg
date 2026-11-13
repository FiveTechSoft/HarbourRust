// t541: after hb_HDel the remaining positions COMPACT (hk163: "bb"
// moves from 2 to 1, "c" from 3 to 2) and a re-added key goes last.
function main()
    local h := {"a" => 1, "bb" => 2, "c" => 3}
    hb_HDel(h, "a")
    ? hb_HPos(h, "bb")
    ? hb_HPos(h, "c")
    h["dd"] := 4
    ? hb_HPos(h, "dd")
return nil
