// t568: hb_HScan answers the 1-based insertion-order position of the
// first entry whose value matches, 0 when absent; the optional start
// is inclusive (hk178).
function main()
    local h := {"a" => 10, "b" => 20, "c" => 10}
    ? hb_HScan(h, 20)
    ? hb_HScan(h, 99)
    ? hb_HScan(h, 10)
    ? hb_HScan(h, 10, 2)
return nil
