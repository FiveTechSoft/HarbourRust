// t570: hb_HScan matches a stored NIL against a NIL argument, and the
// start offset applies to it as to any value (hk180).
function main()
    local h := {"x" => NIL, "y" => 5}
    ? hb_HScan(h, NIL)
    ? hb_HScan(h, 5)
    ? hb_HScan(h, 5, 2)
    ? hb_HScan(h, 5, 3)
return nil
