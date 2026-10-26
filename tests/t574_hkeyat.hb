// t574: hb_HKeyAt answers the key at a 1-based insertion-order
// position, and positions compact after hb_HDel (hk184/hk186).
function main()
    local h := {"bb" => 1, "a" => 2, "ccc" => 3}
    ? hb_HKeyAt(h, 1)
    ? hb_HKeyAt(h, 3)
    hb_HDel(h, "bb")
    ? hb_HKeyAt(h, 1)
    ? hb_HValueAt(h, 1)
return nil
