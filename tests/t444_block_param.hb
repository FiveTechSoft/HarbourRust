function applyit(b, x)
    ? eval(b, x)
return eval(b, x + 1)
function work()
    local dup := {|v| v * 2}
    local r := applyit(dup, 21)
    ? r
    ? eval(dup, 5)
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
