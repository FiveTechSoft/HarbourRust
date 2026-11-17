STATIC a := {"old",NIL}
function main()
? a[1]+shrink()
? Len(a)
return nil
function shrink()
ASize(a,0)
return "!"
