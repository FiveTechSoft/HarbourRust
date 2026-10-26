function main()
   local h := { "alpha" => 1, "beta" => 2 }
   h[ "alpha" ] := 3
   ? h[ "alpha" ]
   ? h[ "beta" ]
   ? hb_memcheck()
   return
