function main()
   local n := 65
   local s := Chr(n)
   ? s, Len(s), Len(Chr(0)), Chr(0) == Chr(256)
   ? Chr(-1) == Chr(255), Chr(257) == Chr(1), Chr(-257) == Chr(255)
   ? Chr(65), Chr(-191), Chr(321), Chr(66+1)
   ? Len("a"+Chr(0)+"b"), "a"+Chr(65)+"b"
return
