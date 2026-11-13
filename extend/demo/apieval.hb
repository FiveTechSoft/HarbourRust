EXTERNAL HBR_EVAL,HBR_BINFO,HBR_ISBQ

function main()
   local b := {|x, y| x + y}
   ? HBR_EVAL(b)
   ? HBR_BINFO(b)
   ? HBR_ISBQ(b)
   ? HBR_BINFO(42)
return nil
