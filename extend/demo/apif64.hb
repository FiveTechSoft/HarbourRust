EXTERNAL HBR_PI,HBR_HALF,HBR_INFO,HBR_TRUNC,HBR_ISNUMQ
function main()
   local p := HBR_PI()
   ? p
   ? valtype(p)
   ? HBR_HALF(7)
   ? HBR_HALF(3.14)
   ? HBR_INFO(3.14)
   ? HBR_TRUNC(p)
   ? HBR_ISNUMQ(3.14), HBR_ISNUMQ("x"), HBR_ISNUMQ(7)
   ? HBR_HALF(24680135790.0)
   return nil
