// assignment to an existing local: i64 and Str, including re-initializing
// a moved string (Rust allows assignment to a moved-out variable)
function main()
    local x := 1
    ? x
    x := x + 4
    ? x
    local a := "hola"
    local b := a
    ? b
    b := "adios"
    ? b
    a := "de nuevo"
    ? a
return nil
