// printing borrows: `a` is still usable after `? a`, then moves to `b`
function main()
    local n := 7
    local a := "hola"
    ? a
    local b := a
    ? b
    ? n
return nil
