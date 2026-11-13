EXTERNAL HBR_LOOPRET,HBR_KEEP,HBR_COPYC,HBR_GETCEMPTY,HBR_MKNUM,HBR_MKSTR,HBR_ECHO,HBR_TY,HBR_GETC,HBR_NILIT
function main()
   local n := HBR_MKNUM()
   local s := HBR_MKSTR()
   local u := HBR_NILIT()
   ? n
   ? s
   ? HBR_ECHO(42), HBR_ECHO("hola"), HBR_ECHO(3.5), HBR_ECHO(.t.), HBR_ECHO()
   ? HBR_TY()
   ? HBR_GETC("abcdef"), HBR_GETC(7)
   ? valtype(u), valtype(n), valtype(s)
   ? HBR_LOOPRET()
   ? HBR_KEEP()
   ? HBR_COPYC("abc")
   ? HBR_GETCEMPTY()
   return nil
