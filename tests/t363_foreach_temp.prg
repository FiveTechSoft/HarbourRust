// FOR EACH over a temporary: the call result is owned by the loop and freed by the epilogue (oracle hk52).
function mk()
    local a := {}
    AAdd(a, "b")
    AAdd(a, "a")
return a
function run()
    local c := ""
    local h := {"k" => 1}
    local n := 0
    for each c in mk()
        if c = "b"
            ? "es-b"
        endif
        if c = "a"
            ? "es-a"
        endif
        n := n + 1
    next
    for each c in hb_HKeys(h)
        if c = "k"
            ? "es-k"
        endif
        n := n + 1
    next
return n
function main()
    ? run()
    ? hb_memcheck()
return nil
