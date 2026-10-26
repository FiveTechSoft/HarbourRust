function main()
   ? LTrim(Chr(9)+"  x ") == "x "
   ? LTrim(Chr(10)+"x") == "x", LTrim(Chr(11)+"x") == "x", LTrim(Chr(12)+"x") == "x", LTrim(Chr(13)+"x") == "x"
   ? LTrim(Chr(8)+"x") == Chr(8)+"x", LTrim(Chr(160)+"x") == Chr(160)+"x"
   ? RTrim("x"+Chr(9)+" ") == "x"+Chr(9), AllTrim(Chr(9)+"x"+Chr(9)) == "x"+Chr(9)
   ? "["+Trim(" x ")+"]", Len(AllTrim(""))
return
