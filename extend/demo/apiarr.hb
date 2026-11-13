EXTERNAL HBR_ARRLEN,HBR_ARRINFA,HBR_ISARRQ,HBR_ARRSUM,HBR_ARRTYPES,HBR_ARRGETPTR,HBR_ARROOB,HBR_ARRNONARR,HBR_ARRREFSUM,HBR_ARRINFO,HBR_ARRPARAMARR
function main()
   local a
   local m
   local e
   a := {10, 20, 5}
   ? HBR_ARRLEN(a)
   ? HBR_ARRSUM(a)
   ? HBR_ARRTYPES(a)
   ? HBR_ARRGETPTR(a)
   ? HBR_ARROOB(a)
   ? HBR_ARRINFO(a)
   ? HBR_ARRPARAMARR(a)
   ? HBR_ARRINFA(a)
   ? HBR_ISARRQ(a), HBR_ISARRQ(42)
   ? HBR_ARRREFSUM(@a)
   m := {"hi", 7, .t., NIL}
   ? HBR_ARRTYPES(m)
   ? HBR_ARRLEN(m)
   e := {9}
   ASize(e, 0)
   ? HBR_ARRLEN(e)
   ? HBR_ARROOB(e)
   ? HBR_ARRNONARR(42)
   ? HBR_ARRNONARR("text")
   return nil
