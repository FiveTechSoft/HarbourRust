function main()
   local d
   local e
   d := { 1, 2, 3 }
   try
      break(d)
   catch e
      e[1] := 99
   end
   ? d[1], e[1]
return nil
