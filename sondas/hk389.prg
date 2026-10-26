function main()
   local n := 65
   ? Chr(n), Len(Chr(0)), Chr(0) == Chr(256), Chr(-1) == Chr(255)
   ? Chr(257), Chr(-191), Chr(65.9), Chr(-190.9)
   ? Len("a"+Chr(0)+"b"), "a"+Chr(0)+"b"
   ? Chr(2147483649.0) == Chr(0), Chr(-2147483649.0) == Chr(0)
return
