function choose(n)
?? n
return n+0 == 1
procedure main()
? "start", IIF(choose(1), "a  ", "wrong "), IIF(choose(2), "wrong", "b   ")
?? IIF(.T., "", "wrong")
? IIF(.F., "wrong", "  ")
? IIF(.T., "x  ", "wrong"), 9
IIF(.T., QOut(IIF(choose(1), "nested  ", "wrong")), QOut("wrong"))
return
