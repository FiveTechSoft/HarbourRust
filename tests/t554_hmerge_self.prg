// t554: hb_HMerge(h, h) self-merge is a clean no-op - same len, same
// values, same positions (hk168, compiled hbmk2 -gtstd, core
// libraries only).
function main()
    local h := {"a" => 1, "bb" => 2}
    hb_HMerge(h, h)
    ? len(h)
    ? h["a"]
    ? h["bb"]
    ? hb_HPos(h, "a")
    ? hb_HPos(h, "bb")
return nil
