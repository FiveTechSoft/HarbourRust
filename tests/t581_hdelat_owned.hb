// t581: hb_HDelAt frees the deleted entry's key copy and everything
// balances at scope exit (wrap + memcheck = 0, own ownership check,
// same pattern as t298; not a Harbour oracle).
function wrap()
    local h := {"aa" => 1, "b" => 2}
    hb_HDelAt(h, 1)
    ? hb_HKeyAt(h, 1)
    return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
