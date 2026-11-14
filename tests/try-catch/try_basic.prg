function main()
   local oErr
   local a := { 1, 2 }
   local i := 5
   try
      ? "in try"
      ? a[ i ]
      ? "after error"
   catch oErr
      ? "caught:", oErr
   finally
      ? "in finally"
   end
   ? "after end"
return nil
