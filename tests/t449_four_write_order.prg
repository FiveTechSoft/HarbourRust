function v()
    ? "V"
return 99
function i1()
    ? "I1"
return 1
function i2()
    ? "I2"
return 2
function i3()
    ? "I3"
return 1
function i4()
    ? "I4"
return 2
function work()
    local a := Array(2, 2, 2, 2)
    a[i1(), i2(), i3(), i4()] := v()
    ? a[1, 2, 1, 2]
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
