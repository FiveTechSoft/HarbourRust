// neg: STATIC FUNCTION is file-local visibility in Harbour; with a
// single compilation unit the visibility domain is one, so a STATIC
// and a plain function with the same name are the duplicate Harbour
// reports too.
STATIC FUNCTION F()
   RETURN 1
FUNCTION F()
   RETURN 2
procedure main()
   return
