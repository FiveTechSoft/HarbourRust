procedure main()
   checks()
   ? hb_memcheck()
return

procedure checks()
   local c := "", i, n := 0, v
   c := "10"
   v := &(c)
   ? ValType(v), v, "|"
   c := "10 + 20 * 3"
   v := &(c)
   ? ValType(v), v, "|"
   c := "-5"
   v := &(c)
   ? ValType(v), v, "|"
   c := "1.5"
   v := &(c)
   ? ValType(v), v, "|"
   c := "1.50"
   v := &(c)
   ? ValType(v), v, "|"
   c := "1.5 * 2"
   v := &(c)
   ? ValType(v), v, "|"
   c := "1.5 + 2"
   v := &(c)
   ? ValType(v), v, "|"
   c := "10 / 2"
   v := &(c)
   ? ValType(v), v, "|"
   c := "10 / 4"
   v := &(c)
   ? ValType(v), v, "|"
   c := "7 % 3"
   v := &(c)
   ? ValType(v), v, "|"
   c := "2 ^ 10"
   v := &(c)
   ? ValType(v), v, "|"
   c := "-2 ^ 2"
   v := &(c)
   ? ValType(v), v, "|"
   c := "2 ** 3"
   v := &(c)
   ? ValType(v), v, "|"
   c := "(1 + 2) * 3"
   v := &(c)
   ? ValType(v), v, "|"
   c := "'abc'"
   v := &(c)
   ? ValType(v), v, "|"
   c := "" + Chr(34) + "abc" + Chr(34) + " + " + Chr(34) + "def" + Chr(34) + ""
   v := &(c)
   ? ValType(v), v, "|"
   c := "" + Chr(34) + "abc  " + Chr(34) + " - " + Chr(34) + "def " + Chr(34) + ""
   v := &(c)
   ? ValType(v), v, "|"
   c := "'a' == 'a'"
   v := &(c)
   ? ValType(v), v, "|"
   c := "1 < 2"
   v := &(c)
   ? ValType(v), v, "|"
   c := ".T. .AND. .F."
   v := &(c)
   ? ValType(v), v, "|"
   c := ".NOT. .T."
   v := &(c)
   ? ValType(v), v, "|"
   c := "!.F."
   v := &(c)
   ? ValType(v), v, "|"
   c := "NIL"
   v := &(c)
   ? ValType(v), v, "|"
   c := "1 = 1.0"
   v := &(c)
   ? ValType(v), v, "|"
   c := "'bc' $ 'xabcx'"
   v := &(c)
   ? ValType(v), v, "|"
   c := "  42  "
   v := &(c)
   ? ValType(v), v, "|"
   c := "9999999999 + 1"
   v := &(c)
   ? ValType(v), v, "|"
   c := "123456789012"
   v := &(c)
   ? ValType(v), v, "|"
   c := "3.14159"
   v := &(c)
   ? ValType(v), v, "|"
   c := "1 / 3"
   v := &(c)
   ? ValType(v), v, "|"
   c := "2.5 * 2.5"
   v := &(c)
   ? ValType(v), v, "|"
   c := "10 - 2.25"
   v := &(c)
   ? ValType(v), v, "|"
   c := "-0.5"
   v := &(c)
   ? ValType(v), v, "|"
   c := ".T."
   v := &(c)
   ? ValType(v), v, "|"
   c := "[abc]"
   v := &(c)
   ? ValType(v), v, "|"
   c := "1.5 * 2.25"
   v := &(c)
   ? ValType(v), v, "|"
   c := "100 / 8"
   v := &(c)
   ? ValType(v), v, "|"
   c := "2 ^ 0.5"
   v := &(c)
   ? ValType(v), v, "|"
   c := "7.5 % 2"
   v := &(c)
   ? ValType(v), v, "|"
   c := "1 + 2 == 3"
   v := &(c)
   ? ValType(v), v, "|"
   c := "" + Chr(34) + "A" + Chr(34) + " < " + Chr(34) + "B" + Chr(34) + ""
   v := &(c)
   ? ValType(v), v, "|"
   c := "1 != 2"
   v := &(c)
   ? ValType(v), v, "|"
   c := "1 <> 1"
   v := &(c)
   ? ValType(v), v, "|"
   c := "1 # 2"
   v := &(c)
   ? ValType(v), v, "|"
   c := "5 >= 5"
   v := &(c)
   ? ValType(v), v, "|"
   c := "" + Chr(34) + "abc" + Chr(34) + " = " + Chr(34) + "ab" + Chr(34) + ""
   v := &(c)
   ? ValType(v), v, "|"
   c := "" + Chr(34) + "ab" + Chr(34) + " = " + Chr(34) + "abc" + Chr(34) + ""
   v := &(c)
   ? ValType(v), v, "|"
   c := "-(3 - 5)"
   v := &(c)
   ? ValType(v), v, "|"
   c := "+7"
   v := &(c)
   ? ValType(v), v, "|"
   c := "0.1 + 0.2"
   v := &(c)
   ? ValType(v), v, "|"
   c := "1000000 * 1000000"
   v := &(c)
   ? ValType(v), v, "|"
   c := ".F. .OR. .T."
   v := &(c)
   ? ValType(v), v, "|"
   c := "5 - 10"
   v := &(c)
   ? ValType(v), v, "|"
   c := "3 * -2"
   v := &(c)
   ? ValType(v), v, "|"
   c := "10.0"
   v := &(c)
   ? ValType(v), v, "|"
   c := ".5"
   v := &(c)
   ? ValType(v), v, "|"
   c := "-123456789012"
   v := &(c)
   ? ValType(v), v, "|"
   c := "2 + 3.0"
   v := &(c)
   ? ValType(v), v, "|"
   c := "5 % 0.0"
   v := &(c)
   ? ValType(v), v, "|"
   c := "2 ^ -1"
   v := &(c)
   ? ValType(v), v, "|"
   c := "" + Chr(34) + "a" + Chr(34) + " + " + Chr(34) + "b" + Chr(34) + " == " + Chr(34) + "ab" + Chr(34) + ""
   v := &(c)
   ? ValType(v), v, "|"
   c := "(((7)))"
   v := &(c)
   ? ValType(v), v, "|"
   c := "1.123456789"
   v := &(c)
   ? ValType(v), v, "|"
   c := "12345678.5 * 2"
   v := &(c)
   ? ValType(v), v, "|"
   c := "-0.0"
   v := &(c)
   ? ValType(v), v, "|"
   c := "0 * -1.5"
   v := &(c)
   ? ValType(v), v, "|"
   c := "1 / 0"
   v := &(c)
   ? ValType(v), v, "|"
   c := "5 % 0"
   v := &(c)
   ? ValType(v), v, "|"
   c := "1.5 / 0"
   v := &(c)
   ? ValType(v), v, "|"
   c := "2.50 + 1.250"
   v := &(c)
   ? ValType(v), v, "|"
   c := "" + Chr(34) + "x" + Chr(34) + " + [y] + 'z'"
   v := &(c)
   ? ValType(v), v, "|"
   c := "1.5 / 0.5"
   v := &(c)
   ? ValType(v), v, "|"
   c := "3.0 / 1.5"
   v := &(c)
   ? ValType(v), v, "|"
   c := "-7 % 3"
   v := &(c)
   ? ValType(v), v, "|"
   c := "7 % -3"
   v := &(c)
   ? ValType(v), v, "|"
   c := "-7.5 % 2"
   v := &(c)
   ? ValType(v), v, "|"
   c := "2 ^ 3 ^ 2"
   v := &(c)
   ? ValType(v), v, "|"
   c := "0x10"
   v := &(c)
   ? ValType(v), v, "|"
   c := ".F. .AND. 1"
   v := &(c)
   ? ValType(v), v, "|"
   c := ".T. .OR. 1"
   v := &(c)
   ? ValType(v), v, "|"
   c := "NIL = 1"
   v := &(c)
   ? ValType(v), v, "|"
   c := "NIL == NIL"
   v := &(c)
   ? ValType(v), v, "|"
   c := ".F. < .T."
   v := &(c)
   ? ValType(v), v, "|"
   c := "" + Chr(34) + "abc" + Chr(34) + " < " + Chr(34) + "abd" + Chr(34) + ""
   v := &(c)
   ? ValType(v), v, "|"
   c := "" + Chr(34) + "ab" + Chr(34) + " < " + Chr(34) + "abc" + Chr(34) + ""
   v := &(c)
   ? ValType(v), v, "|"
   c := "" + Chr(34) + "abc" + Chr(34) + " > " + Chr(34) + "ab" + Chr(34) + ""
   v := &(c)
   ? ValType(v), v, "|"
   c := "" + Chr(34) + "" + Chr(34) + " = " + Chr(34) + "abc" + Chr(34) + ""
   v := &(c)
   ? ValType(v), v, "|"
   c := "" + Chr(34) + "abc" + Chr(34) + " = " + Chr(34) + "" + Chr(34) + ""
   v := &(c)
   ? ValType(v), v, "|"
   c := ".Y."
   v := &(c)
   ? ValType(v), v, "|"
   c := "nil"
   v := &(c)
   ? ValType(v), v, "|"
   c := ".n."
   v := &(c)
   ? ValType(v), v, "|"
   c := "10 - 2 - 3"
   v := &(c)
   ? ValType(v), v, "|"
   c := "100 / 10 / 4"
   v := &(c)
   ? ValType(v), v, "|"
   c := "2 * 3 % 4"
   v := &(c)
   ? ValType(v), v, "|"
   c := "" + Chr(34) + "abc" + Chr(34) + " != " + Chr(34) + "ab" + Chr(34) + ""
   v := &(c)
   ? ValType(v), v, "|"
   c := "" + Chr(34) + "abc" + Chr(34) + " == " + Chr(34) + "abc " + Chr(34) + ""
   v := &(c)
   ? ValType(v), v, "|"
   c := "" + Chr(34) + "ab" + Chr(34) + " <= " + Chr(34) + "abc" + Chr(34) + ""
   v := &(c)
   ? ValType(v), v, "|"
   c := "" + Chr(34) + "abc" + Chr(34) + " >= " + Chr(34) + "ab" + Chr(34) + ""
   v := &(c)
   ? ValType(v), v, "|"
   c := "1 == 1.0"
   v := &(c)
   ? ValType(v), v, "|"
   c := "1.0 = 1.00"
   v := &(c)
   ? ValType(v), v, "|"
   c := "7 / 7"
   v := &(c)
   ? ValType(v), v, "|"
   c := "-6 / 3"
   v := &(c)
   ? ValType(v), v, "|"
   c := "9007199254740993"
   v := &(c)
   ? ValType(v), v, "|"
   c := "2 ^ 64"
   v := &(c)
   ? ValType(v), v, "|"
   c := "1000000000 * 10"
   v := &(c)
   ? ValType(v), v, "|"
   c := "-1000000000 * 1"
   v := &(c)
   ? ValType(v), v, "|"
   c := "3 - 0.5 - 0.25"
   v := &(c)
   ? ValType(v), v, "|"
   c := ".T. = .T."
   v := &(c)
   ? ValType(v), v, "|"
   c := ".T. != .F."
   v := &(c)
   ? ValType(v), v, "|"
   c := ".F. .AND. hidden"
   v := &(c)
   ? ValType(v), v, "|"
   c := ".T. .OR. hidden"
   v := &(c)
   ? ValType(v), v, "|"
   c := "hidden .AND. .F."
   v := &(c)
   ? ValType(v), v, "|"
   c := "&('1')"
   v := &(c)
   ? ValType(v), v, "|"
   c := "&('2 * ' + '3')"
   v := &(c)
   ? ValType(v), v, "|"
   c := "(1,2)"
   v := &(c)
   ? ValType(v), v, "|"
   c := "(1, 'a', .T.)"
   v := &(c)
   ? ValType(v), v, "|"
   c := "9223372036854775807+1"
   v := &(c)
   ? ValType(v), v, "|"
   c := "'&name.'"
   v := &(c)
   ? ValType(v), v, "|"
   c := ".F. .AND. ('a' + 1)"
   v := &(c)
   ? ValType(v), v, "|"
   ? &("1 + 1"), &c
   for i := 1 to 200
      c := "'x' + 'y' - 'z  '"
      if &(c) == "xyz  "
         n++
      endif
      c := "3 * " + hb_ntos(i) + " % 7"
      if &(c) > 0
         n++
      endif
   next
   ? n
return
