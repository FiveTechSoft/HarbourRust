// Negative: the expression before the statement separator is incomplete.
// hk368/hk479 reject this; complete same-line statements are supported.
function main()
    local a := 1 + ; comment after semi
        2
    return nil
