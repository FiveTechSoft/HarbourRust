EXTERNAL HBR_SETARR
function main()
   local a
   a := {10, 20}
   ? HBR_SETARR(@a)
   ? "unreachable"
   return nil
