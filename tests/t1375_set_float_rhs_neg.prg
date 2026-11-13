// neg: inline `:=` with a float payload stays a named limit (the Dyn
// float representation decision is pending; no faking).
function main()
    local y
    ? ( y := 2.5, y )
    return nil
