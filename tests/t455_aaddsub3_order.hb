function v()
    ? "V"
return 8
function i1()
    ? "I1"
return 1
function i2()
    ? "I2"
return 2
function i3()
    ? "I3"
return 1
function work()
    local a := Array(2, 2, 2, 2)
    AAdd(a[i1(), i2(), i3()], v())
    ? len(a[1, 2, 1])
    ? a[1, 2, 1, 3]
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
