function echo(x)
return x+0
function main()
local x := 1
? x++, x, ++x, x
x := 1
? x++ + x++, x
x := 1
? ++x + x++, x
x := 0
? .F. .AND. x++ > 0, x
? .T. .OR. x++ > 0, x
? IIF(.T., x++, ++x), x
? echo(x++), x
x := 0
do while x++ < 3
? x
enddo
? x
return
