// A hash parameter the callee does not return is freed at the callee's
// exit (the caller moved it in, so main holds nothing): balance 0.
// len(p) merges with the string-key read: the hash pin wins (hk11).
function consume(p)
    ? p["a"]
    ? len(p)
return 0
function main()
    local h := {"a" => 1, "b" => 2}
    local r := consume(h)
    ? hb_memcheck()
return nil
