function main()
? ProcLine(), ;
  ProcLine()
? (1,ProcLine())
? IIF(.T., ProcLine(), 0)
? Eval({|| ProcLine(), ;
          ProcLine()})
return
