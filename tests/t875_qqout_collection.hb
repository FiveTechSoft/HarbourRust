function main()
   local a := {1,2}
   local h := {"x"=>1}
   local r := QQOut("left", a, "mid", h, "end")
   ? r == NIL, Len(a), Len(h)
return
