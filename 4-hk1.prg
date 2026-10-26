PROCEDURE Main()
   LOCAL h := {=>}
   LOCAL k
   h["beta"] := 1
   h["Alpha"] := 2
   h["gamma"] := 3
   k := HGetKeys(h)
   ? LEN(k)
   ? k[1]
   ? k[2]
   ? k[3]
RETURN
