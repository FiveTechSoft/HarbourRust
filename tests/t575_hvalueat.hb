// t575: hb_HValueAt answers the value at a 1-based insertion-order
// position; a stored NIL comes back as NIL (hk185).
function main()
    local h := {"x" => 10, "y" => NIL, "z" => 30}
    ? hb_HValueAt(h, 1)
    ? hb_HValueAt(h, 2)
    ? hb_HValueAt(h, 3)
return nil
