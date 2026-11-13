function combine(b1, b2, x)
return eval(b1, eval(b2, x))
function work()
    local dup := {|v| v * 2}
    local inc := {|v| v + 1}
    ? combine(dup, inc, 5)
    ? combine(inc, dup, 5)
return 0
function main()
    ? work()
    ? hb_memcheck()
return nil
