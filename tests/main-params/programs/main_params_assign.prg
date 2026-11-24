// Parameters of main start NIL and take any value afterwards.
procedure main(cYear, mode)
   ? valtype(cYear), valtype(mode)
   ? cYear
   if cYear == NIL
      ? "no year|"
   endif
   if valtype(mode) != "N"
      mode := 0
   endif
   ? mode
   cYear := "2024"
   ? cYear + "|"
return
