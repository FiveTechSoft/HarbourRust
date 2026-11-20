FUNCTION FailS()
 Break("expected")
RETURN Upper("never")
FUNCTION FailI()
 Break("expected")
RETURN 1
FUNCTION Work()
 LOCAL i,s:=Upper("alive"),d:="",n:=0,f:=0.0
 FOR i:=1 TO 1000
  d:=(Upper("prefix"),s)
  f:=(Upper("prefix"),1.25)
  Len((Upper("prefix"),s))
  (Upper("discard"),Lower("discard"))
  TRY
   d:=(Upper("discard"),FailS())
  CATCH e
   n++
  END
  TRY
   ? (Upper("prefix"),s),FailI()
  CATCH e
   n++
  END
 NEXT
RETURN n
FUNCTION Main()
 LOCAL b:=0
 Work()
 b:=hb_memcheck()
 OutStd(Work(),hb_memcheck()-b,Chr(10))
RETURN NIL
