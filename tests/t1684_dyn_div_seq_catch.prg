function main()
   local e, a, b
   a := NIL
   try
      ? a / 2
      ? "no error"
   catch e
      ? "caught:", e
   end
   try
      ? 2 / a
      ? "no error"
   catch e
      ? "caught:", e
   end
   a := 10
   b := 0
   try
      ? a / b
      ? "no error"
   catch e
      ? "caught:", e
   end
   a := "xy"
   try
      ? a / 2
      ? "no error"
   catch e
      ? "caught:", e
   end
   a := .T.
   try
      ? a / 2
      ? "no error"
   catch e
      ? "caught:", e
   end
   ? "after"
return nil
