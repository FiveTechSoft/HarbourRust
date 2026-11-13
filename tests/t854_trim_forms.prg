function main()
   ? "["+LTrim("  a b  ")+"]", "["+RTrim("  a b  ")+"]", "["+AllTrim("  a b  ")+"]"
   ? Len(LTrim("")), Len(RTrim("  ")), Len(AllTrim("   "))
   ? LTrim(Chr(9)+" x ") == Chr(9)+" x "
   ? RTrim(" x "+Chr(9)) == " x "+Chr(9)
   ? AllTrim(" "+Chr(0)+" ") == Chr(0)
   ? AllTrim(" "+Chr(160)+" ") == Chr(160)
return
