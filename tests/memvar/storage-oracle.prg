MEMVAR p, pub, fresh, v, implicitNew
function Line(k,x)
local s
if ValType(x)=="U"
s := "NIL"
elseif ValType(x)=="L"
s := iif(x,"T","F")
elseif ValType(x)=="N"
s := LTrim(Str(x))
else
s := x
endif
OutStd(k+"="+s+Chr(10))
return nil
function Child()
Line("child.inherited",p)
p := 12
private p := 20
Line("child.shadow",p)
Grand()
Line("child.after.grand",p)
return nil
function Grand()
p := 21
return nil
function ReleaseChild()
private pub:=99
release pub
Line("release.shadow",pub)
return nil
function Failing()
private p := 99
Break("exit")
return nil
function Implicit()
implicitNew := 88
Line("implicit.inside",implicitNew)
return nil
function Main()
local e,c,a:=Replicate("A",63)
public pub
Line("public.default",pub)
pub:=50
public pub
Line("public.redeclare",pub)
ReleaseChild()
Line("release.shadow.restored",pub)
private p:=10
Child()
Line("parent.restored",p)
Line("case", &("P"))
begin sequence with {|err| Break(err)}
Failing()
recover using e
Line("unwind.restored",p)
end sequence
private fresh
Line("private.default",fresh)
fresh:=8
private fresh
Line("private.redeclare",fresh)
private fresh:=9
Line("private.reinit",fresh)
release fresh
Line("release.private",fresh)
Line("release.private.exists",__mvExist("fresh"))
public publicOnly
Line("public.exists",__mvExist("publicOnly"))
release publicOnly
Line("release.public.exists",__mvExist("publicOnly"))
Implicit()
Line("implicit.after",__mvExist("implicitNew"))
__mvPut(a,11)
__mvPut(a+"B",22)
Line("long63",__mvGet(a))
Line("long64",__mvGet(a+"C"))
private v:="first"
c:=v
v:="second"
Line("string.copy",c)
Line("string.current",v)
v:=""
Line("empty.type",ValType(v))
Line("empty.length",Len(v))
public HARBOUR, CLIPPER
Line("default.HARBOUR",HARBOUR)
Line("default.CLIPPER",CLIPPER)
return nil
