// both collection index expressions evaluate ONCE, effects included (hk64).
function ni()
    ? "eval"
return 1
function main()
    local a := {{{1, 2}}, {{3, 4}}}
    local x := 0
    for each x in a[ni()][ni()]
        ? x
    next
return nil
