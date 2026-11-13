function i1()
    ? "I1"
return 1
function i2()
    ? "I2"
return 2
function i3()
    ? "I3"
return 1
function main()
    local a := Array(2, 2, 2, 2)
    local x
    a[1, 2, 1, 1] := 5
    for each x in a[i1(), i2(), i3()]
        ? x
    next
return nil
