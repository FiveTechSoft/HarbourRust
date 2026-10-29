function echo(n)
return n+0
function mark(n)
? n
return n+0
function main()
local x := 1
local a := {7,8,9}
? (x++,12345678901), x
? (x++,x) + (x++,x), x
? (mark(1),mark(2),x), x
? echo((x++,x)), x
? If((x++,x > 0),1,0), x
? If(.F. .AND. (x++, x > 0),1,0), x
? If(.T. .OR. (x++, a[0+x] == 0),1,0), x
x := 0
while (x++, x < 3)
? x
enddo
? x
x := 0
? a[(x++,x)], x
x := 0
a[(x++,x)] := (x++,x*10)
? x, a[1], a[2]
? (1,(2,(3,4)))
return
