function main()
 local t := Time()
 ? Len(t)
 ? SubStr(t, 3, 1) == ":" .and. SubStr(t, 6, 1) == ":"
 ? Val(SubStr(t, 1, 2)) >= 0 .and. Val(SubStr(t, 1, 2)) <= 23
 ? Val(SubStr(t, 4, 2)) >= 0 .and. Val(SubStr(t, 4, 2)) <= 59
 ? Val(SubStr(t, 7, 2)) >= 0 .and. Val(SubStr(t, 7, 2)) <= 59
 ? ValType(t)
return nil
