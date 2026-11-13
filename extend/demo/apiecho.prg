EXTERNAL HBR_ECHO,HBR_RET35

function main()
   ? 3.5
   ? HBR_ECHO(3.5)
   ? 3.14159
   ? HBR_ECHO(3.14159)
   ? 1.5+2.25
   ? HBR_ECHO(1.5+2.25)
   ? HBR_RET35()
   ? 42, "hola", 3.5, .T.
   ? 42, "hola", HBR_ECHO(3.5), .T.
   ? 42, "hola", HBR_ECHO(3.14159), .T.
   ? 42, "hola", HBR_ECHO(1.5+2.25), .T.
   ? 42, "hola", HBR_RET35(), .T.
return nil
