function main()
   local d, i
   d := 0.0001
   for i := 1 to 500
      hb_idleSleep(d)
   next
   ? d
return nil
