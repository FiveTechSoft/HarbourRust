#define F(x) ++x
#define G(x) x--
#define H(x) x
FUNCTION Main()
LOCAL n:=3
? F(n),G(n),H(n++),n
RETURN NIL
