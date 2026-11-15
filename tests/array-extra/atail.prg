function main()
   local a := Array(3)
   a[1] := 10
   a[2] := 20
   a[3] := 30
   ? atail(a)
   local s := {"aa", "bb"}
   ? atail(s)
   local e := Array(0)
   ? atail(e)
   return nil
