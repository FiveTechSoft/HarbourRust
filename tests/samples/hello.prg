// Programa valido: sintaxis Harbour, reglas Rust
function saludo()
    local s := "hola desde una funcion"
return s

function main()
    local x := 10
    local y := 3
    local z := x * y + 2
    ? "resultado de z:"
    ? z
    ? saludo()
return nil
