// left shorter than right under `=`: .F. (oracle hk48); `<>` .T.
function main()
    local a := {}
    local c := ""
    AAdd(a, "a")
    AAdd(a, "ab")
    for each c in a
        if c = "abc"
            ? "igual"
        else
            ? "distinta"
        endif
        if c <> "abc"
            ? "ne"
        endif
    next
return nil
