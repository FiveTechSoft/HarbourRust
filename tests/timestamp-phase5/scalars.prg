FUNCTION CheckValue(x)
RETURN Empty(x)
FUNCTION Main()
 LOCAL t:=hb_SToT("20261123")
 ? CheckValue(NIL),CheckValue(0),CheckValue(1),CheckValue(-1),CheckValue(.F.),CheckValue(.T.)
 ? CheckValue(""),CheckValue(" "),CheckValue(Chr(9)+Chr(10)+Chr(13)),CheckValue(" x ")
 ? CheckValue(t),CheckValue(hb_SToT("")),CheckValue(hb_SToT("00000000101530"))
RETURN NIL
