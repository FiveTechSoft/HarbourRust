function main()
   local v
   try
      ? "in try"
      break("sentinel")
      ? "unreachable"
   catch v
      ? "caught:", v
   end
   ? "after end"
return nil
