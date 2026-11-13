// t523: hb_HDel frees the hash-owned key copy on removal - balance 0
// after the function returns (own ownership check, same pattern as
// t298/t520; not a Harbour oracle).
function wrap()
    local h := {"a" => 1, "bb" => 2, "c" => 3}
    hb_HDel(h, "bb")
    hb_HDel(h, "a")
    return len(h)
function main()
    ? wrap()
    ? hb_memcheck()
return nil
