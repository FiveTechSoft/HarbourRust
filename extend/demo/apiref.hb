EXTERNAL HBR_BUMP,HBR_STORC_RC,HBR_SETS,HBR_SETD,HBR_SETL,HBR_ISREF,HBR_INFO2,HBR_PI
function main()
   local u
   local d
   local l
   u := 5
   HBR_BUMP(@u)
   ? u
   HBR_SETS(@u)
   ? u, valtype(u)
   d := HBR_PI()
   HBR_SETD(@d)
   ? d
   l := .t.
   HBR_SETL(@l)
   ? l
   ? HBR_ISREF(@u), HBR_ISREF(u)
   ? HBR_STORC_RC(@u), HBR_STORC_RC(u)
   ? HBR_INFO2(@u)
   return nil
