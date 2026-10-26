function main()
    local x, y, i
    for i := 1 to 2
        if i == 1
            x := {|n| n + 1}
        else
            y := {|n| n + 1}
        endif
    next
    ? x == y
    ? x == x
return nil
