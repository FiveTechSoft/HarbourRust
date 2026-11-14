procedure main()
   descend(3)
return
function descend(n)
   if n > 0
      descend(n-1)
   else
      ? ProcName(0),ProcLine(0),ProcName(1),ProcLine(1)
      ? ProcName(2),ProcLine(2),ProcName(3),ProcLine(3)
      ? ProcName(4),ProcLine(4),ProcName(5),ProcLine(5)
   endif
return nil
