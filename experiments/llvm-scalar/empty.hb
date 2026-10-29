function mark(n)
? n
return n+0
function main()
local x := 0
local b := .F.
local a := {0,0}
local low := -9223372036854775807
low -= 1
? If(Empty(0),1,0),If(Empty(1),1,0),If(Empty(-1),1,0),If(Empty(low),1,0)
? If(Empty(.F.),1,0),If(Empty(.T.),1,0),If(Empty(a),1,0)
b := Empty(x++)
? If(b,1,0),x
? If(Empty(++x),1,0),x
? If(Empty(mark(0)),1,0),If(Empty(mark(9)),1,0)
? If(Empty(.F. .AND. (++x > 0)),1,0),x
? If(Empty((x++,0)),1,0),x
? If(Empty(a[1]),1,0)
return
