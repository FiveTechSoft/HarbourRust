// t520: the hb_HValues result is freed by the DArr epilogue - balance
// 0 after the function returns (own ownership check, same pattern as
// t298; not a Harbour oracle).
function wrap()
    local h := {"a" => 1, "bb" => 2}
    local v := hb_HValues(h)
    ? v[2]
    return len(v)
function main()
    ? wrap()
    ? hb_memcheck()
return nil
