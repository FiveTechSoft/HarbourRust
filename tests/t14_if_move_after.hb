// a string moved on one path counts as moved at the join (like Rust)
function main()
    local a := "hola"
    if 1 < 2
        local b := a
        ? b
    endif
    ? a
return nil
