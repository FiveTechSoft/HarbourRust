FUNCTION Pick(flag)
 IF flag
  RETURN 9007199254740993
 ENDIF
RETURN NIL
FUNCTION Main()
 LOCAL d, r
 ? "owned", Int(Pick(.T.))
 d := Pick(.T.)
 ? "slot", Int(d)
 r := Int(Pick(.T.))
 ? "saved", r
RETURN NIL
