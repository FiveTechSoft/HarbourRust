function clean(s)
return AllTrim(s)
function exercise()
   local s := "  abc  "
   local t := AllTrim(s)
   ? s, t, Len(AllTrim("  ")), Len(LTrim(Chr(9)+" x "))
   t := RTrim(AllTrim(" q ")+"  ")
   ? t
   ? clean(" z ")
return
function main()
   exercise()
   ? hb_MemCheck()
return
