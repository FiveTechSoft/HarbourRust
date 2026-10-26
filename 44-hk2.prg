PROCEDURE Main()
   LOCAL h := {=>}
   LOCAL k
   h["one"] := 1
   h["one"] := 9
   h["ONE"] := 7
   k := HGetKeys(h)
   ? LEN(k)
   ? k[1]
   ? h[k[1]]
RETURN
