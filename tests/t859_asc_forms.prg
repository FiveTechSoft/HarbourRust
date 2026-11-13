function main()
   local s := "AZ"
   ? Asc(""), Asc("A"), Asc(s), Asc(Chr(0)), Asc(Chr(255)), Asc(Chr(128))
   ? Asc("abc"), Asc(Chr(-1)), Asc(Chr(257)), Asc(Chr(65)+"Z")
   ? Asc(Chr(9)), Asc(Chr(10)), Asc(Chr(13)), Asc(Chr(32))
   ? Asc(LTrim(" A")), Asc(RTrim("Z ")), Asc(AllTrim(" B "))
return
