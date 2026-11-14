procedure main()
   StepTwo()
return
function StepTwo()
   StepThree()
return nil
function StepThree()
   local n
   for n := -2 to 8
      ? n, "<" + ProcName(n) + ">", ProcLine(n)
   next
return nil
