function main()
   local n
   for each n in { -257, -256, -1, 0, 1, 65, 127, 128, 255, 256, 257, 511, 1.9, -1.9 }
      ? n, Len( Chr(n) ), Asc( Chr(n) )
   next
   ? "a" + Chr(0) + "b", Len("a" + Chr(0) + "b")
return
