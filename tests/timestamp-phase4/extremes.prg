FUNCTION Compare(a,b)
RETURN iif(a<b,-1,iif(a>b,1,0))
FUNCTION Main()
 LOCAL a:=hb_SToT("00000101000000000"),b:=hb_SToT("99991231235959999"),e:=hb_SToT(""),t:=hb_SToT("00000000000000001")
 ? Compare(a,b),Compare(b,a),Compare(a,e),Compare(t,e),Compare(e,t)
 ? b==hb_SToT("99991231235959999"),a==hb_SToT("00000101000000000"),e==hb_SToT("")
RETURN NIL
