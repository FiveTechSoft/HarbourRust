FUNCTION mark(n)
? n
RETURN n+0
FUNCTION Main()
LOCAL a:={10,20,30},i:=0
? (a[++i]+=mark(5)),i
? (a[i++] *= (i:=3)),i
? a[1],a[2],a[3]
? (a[1]+=(a[1]*=2)),a[1]
? (a[2]-=(a[2]+=4)),a[2]
? IIf(.T.,(a[3]+=mark(7)),(a[3]+=mark(99)))
? a[3]
RETURN NIL
