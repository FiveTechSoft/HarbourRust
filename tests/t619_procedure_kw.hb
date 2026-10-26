// t619: PROCEDURE is Harbour's function keyword and identifiers are
// case-insensitive - MAIN/Main/main are one name, and so are locals
// and calls in any casing (upstream tests/*.prg style). Forward
// references (call before definition) are NOT in this increment.
PROCEDURE SALUDA()
    LOCAL k := 1
    ? k
RETURN
PROCEDURE Main()
    LOCAL MiVar := 7
    ? MIVAR
    ? mivar + 1
    ? Saluda()
RETURN
