// if/else/endif: comparisons, nesting, branch-scoped locals
function main()
    local x := 7
    if x > 5
        ? "big"
    else
        ? "small"
    endif
    if x >= 7
        if x <= 7
            ? "exactly seven"
        endif
    endif
    if x = 7
        ? "eq"
    endif
    if x <> 8
        ? "ne"
    endif
    if x != 7
        ? "bad"
    else
        ? "ne2 ok"
    endif
    if x < 10
        ? "lt"
    endif
    local y := 1
    if y = 1
        local z := 40
        ? z + 2
    endif
return nil
