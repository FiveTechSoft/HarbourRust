FUNCTION Unused(p)
RETURN p
FUNCTION Forward(p)
 LOCAL x := p
RETURN x
FUNCTION Holder(a, b)
RETURN Forward(b)
PROCEDURE Main()
 LOCAL u := NIL
 ? Forward("texto"), Forward(7), Forward(.T.), Forward(u)
 ? Holder(1, "segundo"), Holder("x", 9)
RETURN
