// neg: a mixed scalar literal is supported (piece 1a), but a non-literal
// element (a variable) is not - the named rejection stands.
function main()
    local x := 1
    local a := {"a", x}
return nil
