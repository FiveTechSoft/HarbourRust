// advancing the counter below -i64::MAX - 1 must end the loop, not wrap it
// (the start expression uses 0 - n because the grammar has no unary minus)
function main()
    for i := 0 - 9223372036854775807 to 0 - 9223372036854775807 step -2
        ? i
    next
    ? "fin"
return nil
