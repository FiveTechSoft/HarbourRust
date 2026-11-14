function main()
   local oErr
   try
      ? "in try"
   catch oErr
      ? "caught:", oErr
   finally
      ? "in finally"
   end
   ? "after end"
return nil
