// string equality/inequality in conditions: Harbour default (SET EXACT
// OFF) `=` compares over the RIGHT operand's length: "hola" = "hol" and
// "holaa" = "hol" are true, "hola" = "holaa" is false (probe b23).
// Literals, variables, different lengths, prefix relations, while cond.
function main()
    local a := "hola"
    local b := "hola"
    local c := "holaa"
    local d := "hol"
    if a = b
        ? "eq1"
    endif
    if a = "hola"
        ? "eq2"
    endif
    if a = c
        ? "no"
    endif
    if a = d
        ? "no"
    endif
    if c = d
        ? "no"
    endif
    if a <> c
        ? "ne1"
    endif
    if "x" = "x"
        ? "eq3"
    endif
    if "" = ""
        ? "eq4"
    endif
    if "" <> "x"
        ? "ne2"
    endif
    local s := "go"
    while s <> "stop"
        ? s
        s := "stop"
    enddo
    ? "fin"
return nil
