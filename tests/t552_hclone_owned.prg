// t552: hb_HClone ownership - the clone and the source are freed
// independently at scope exit with no leak and no double free (wrap +
// memcheck = 0, own ownership check, same pattern as t298; not a
// Harbour oracle).
function wrap()
    local h := {"a" => 1, "bb" => 2}
    local c := hb_HClone(h)
    c["a"] := 7
    ? c["a"]
    ? h["a"]
    return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
