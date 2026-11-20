function FailI()
Break("kept")
return 1
function Work()
local h:={=>},b:={=>},i,d,z,n:=0
for i:=1 to 1000
 d:=Upper("old-value")
 h["k"]:=d
 d:=Upper("new-value")
 z:=Upper("bad-value")
 h["k"]:=h["k"]
 b:=hb_HClone(h)
 hb_HClear(h)
 hb_HCopy(b,h)
 hb_HDelAt(b,1)
 hb_HMerge(b,h)
 hb_HFill(h,7)
 hb_HDel(b,"k")
 hb_HClear(h)
 h:={"a"=>"literal","b"=>""}
 hb_HSet(h,"c","third")
 hb_HClear(h)
 TRY
  h:={"x"=>"unwind"}
  ? FailI()
 CATCH e
  n++
 END
 hb_HClear(h)
next
return n
function Main()
local b
Work()
b:=hb_memcheck()
OutStd(Work(),hb_memcheck()-b,Chr(10))
return nil
