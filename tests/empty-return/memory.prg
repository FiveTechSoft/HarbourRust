FUNCTION EmptyA()
 LOCAL a:={}
RETURN a
FUNCTION Wrap()
RETURN EmptyA()
FUNCTION Consume(s)
RETURN {}
FUNCTION FailI()
 Break("kept")
RETURN 1
FUNCTION Work()
 LOCAL i,n:=0,x:=0
 FOR i:=1 TO 1000
  x:=Len(EmptyA())+Len({})+Len(Wrap())
  x:=Len(Consume(Upper("owned argument")))
  TRY
   ? Len(EmptyA()),FailI()
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
