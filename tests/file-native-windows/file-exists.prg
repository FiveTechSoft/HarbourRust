PROCEDURE Main()
 LOCAL a := NIL
 LOCAL s := "Exact.TXT"
 ? "exact", File("Exact.TXT"), File("exact.txt"), File("absent"), File("")
 ? "dirs", File("sub"), File("sub/"), File("."), File("..")
 ? "nested", File("sub/nested.txt"), File("sub\nested.txt"), File("sub\absent.txt")
 ? "glob", File("*.TXT"), File("*.zzz"), File("noext.*"), File("Exact.???"), File("sub\*.txt")
 ? "hidden", File("oculto.txt"), File("sistema.txt")
 ? "type", File(NIL), File(1), File(.T.), File(2.5), File(Date())
 ? "owned", File(SubStr("_Exact.TXT", 2)), File(Upper("exact.txt")), File(s), File(s + ".no")
 a := "Exact.TXT"
 ? "dynstr", File(a)
 a := "absent"
 ? "dynabsent", File(a)
 a := 19
 ? "dynint", File(a)
 a := .T.
 ? "dynbool", File(a)
 a := 2.5
 ? "dynfloat", File(a)
 a := NIL
 ? "dynnil", File(a)
 IF File(s) .AND. ! File("absent")
  ? "condition", "ok"
 ENDIF
RETURN
