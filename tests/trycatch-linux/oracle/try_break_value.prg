function main()
   local v
   begin sequence
      ? "in try"
      break("sentinel")
      ? "unreachable"
   recover using v
      ? "caught:", v
   end sequence
   ? "after end"
return nil
