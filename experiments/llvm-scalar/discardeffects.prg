function tick(n)
?? n
return n + 0
procedure main()
local n := 0
IIF(.T., QOut("chosen", tick(1)), QOut("wrong", tick(99)))
IIF(.F., QOut("wrong"), QQOut("inline", tick(2)))
IIF(.T., NIL, QOut("wrong"))
IIF(.F., QOut("wrong"), NIL)
? (QOut("prefix"), (n++, n)), n
IIF(.T., IIF(.F., tick(98), tick(7)), tick(99))
(QQOut("seq"), QQOut(tick(3)), 4)
return
