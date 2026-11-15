function main()
   local a := Array(3)
   a[1] := 30
   a[2] := 10
   a[3] := 20
   asort(a)
   ? a[1], a[2], a[3]
   local b := Array(5)
   b[1] := 5
   b[2] := 4
   b[3] := 3
   b[4] := 2
   b[5] := 1
   asort(b, 2, 2)
   ? b[1], b[2], b[3], b[4], b[5]
   local s := {"bb", "cc", "aa"}
   asort(s)
   ? s[1], s[2], s[3]
   return nil
