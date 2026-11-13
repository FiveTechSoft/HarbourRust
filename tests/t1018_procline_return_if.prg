function myrow(n)
? ProcLine()
return ProcLine(0)+n
function main()
? myrow(1)
if .T.
? ProcLine()
endif
? IIF(.T., ProcLine(), ProcLine())
return
