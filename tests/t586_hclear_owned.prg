// t586: hb_HClear frees every key copy and the block, hb_HFill owns
// nothing, and everything balances at scope exit (wrap + memcheck =
// 0, own ownership check, same pattern as t298; not a Harbour
// oracle).
function wrap()
    local h := {"aa" => 1, "b" => 2, "ccc" => 3}
    hb_HFill(h, 5)
    ? h["b"]
    hb_HClear(h)
    ? len(h)
    h["z"] := 1
    ? hb_HKeyAt(h, 1)
    return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
