function echo(x)
return x+0
function main()
local x := 5
local b := {|n| n++, ++n}
? x - -x, x
? x + ++x, x
? x++ + ++x, x
? --x + x--, x
? x++ % 3, x
? echo(++x), x
? Eval(b, 2), x
return
