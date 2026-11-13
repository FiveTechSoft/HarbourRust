// t576: hb_HKeyAt returns an OWNED copy of the key: it prints after
// the source hash is already gone (wrap exit) and nothing leaks
// (wrap + memcheck = 0, own ownership check, same pattern as t298;
// not a Harbour oracle).
function wrap()
    local h := {"aa" => 1, "b" => 2}
    return hb_HKeyAt(h, 2)
function main()
    ? wrap()
    ? hb_memcheck()
return nil
