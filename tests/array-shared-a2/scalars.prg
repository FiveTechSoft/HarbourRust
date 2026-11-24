FUNCTION ReadValue(v)
RETURN ValType(v)
FUNCTION Work()
   LOCAL a := {}, b := a
   AAdd(b, CToD("20261123"))
   AAdd(b, hb_SToT("20261123123456789"))
   AAdd(b, 2.5)
   AAdd(b, "owned" + Str(1,2))
   ? ReadValue(a[1]), ReadValue(a[2]), ReadValue(a[3]), ReadValue(a[4]), hb_TToS(a[2])
RETURN NIL
FUNCTION Main()
   Work()
RETURN NIL
