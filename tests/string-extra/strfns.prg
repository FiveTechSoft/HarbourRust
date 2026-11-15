procedure main()
   OutStd("padc1=[" + PadC("ab", 6) + "]" + Chr(10))
   OutStd("padc2=[" + PadC("abc", 6) + "]" + Chr(10))
   OutStd("padc3=[" + PadC("abc", 6, "*") + "]" + Chr(10))
   OutStd("padc4=[" + PadC("abcdef", 3) + "]" + Chr(10))
   OutStd("padc5=[" + PadC("abcdefg", 4) + "]" + Chr(10))
   OutStd("padc6=[" + PadC("ab", 0) + "]" + Chr(10))
   OutStd("padc7=[" + PadC("ab", -2) + "]" + Chr(10))
   OutStd("padc8=[" + PadC("", 3, "xy") + "]" + Chr(10))
   OutStd("rat1=" + Str(RAt("a", "banana"), 10) + Chr(10))
   OutStd("rat2=" + Str(RAt("an", "banana"), 10) + Chr(10))
   OutStd("rat3=" + Str(RAt("x", "banana"), 10) + Chr(10))
   OutStd("rat4=" + Str(RAt("", "banana"), 10) + Chr(10))
   OutStd("rat5=" + Str(RAt("banana", "ban"), 10) + Chr(10))
   OutStd("rat6=" + Str(RAt("b", "banana"), 10) + Chr(10))
   OutStd("rat7=" + Str(RAt("a", ""), 10) + Chr(10))
   OutStd("stuff1=[" + Stuff("abcdef", 2, 1, "X") + "]" + Chr(10))
   OutStd("stuff2=[" + Stuff("abcdef", 2, 0, "XY") + "]" + Chr(10))
   OutStd("stuff3=[" + Stuff("abcdef", 2, 3, "") + "]" + Chr(10))
   OutStd("stuff4=[" + Stuff("abcdef", 0, 1, "X") + "]" + Chr(10))
   OutStd("stuff5=[" + Stuff("abcdef", 10, 1, "X") + "]" + Chr(10))
   OutStd("stuff6=[" + Stuff("abcdef", 5, 10, "X") + "]" + Chr(10))
   OutStd("stuff7=[" + Stuff("abcdef", -1, 1, "X") + "]" + Chr(10))
   OutStd("stuff8=[" + Stuff("abcdef", 3, -1, "X") + "]" + Chr(10))
   OutStd("stuff9=[" + Stuff("", 1, 0, "X") + "]" + Chr(10))
   OutStd("stuff10=[" + Stuff("abcdef", 7, 0, "X") + "]" + Chr(10))
   OutStd("isd=" + IIf(IsDigit("1a"), "T", "F") + IIf(IsDigit("a1"), "T", "F") + IIf(IsDigit(""), "T", "F") + IIf(IsDigit(" 1"), "T", "F") + Chr(10))
   OutStd("isa=" + IIf(IsAlpha("a1"), "T", "F") + IIf(IsAlpha("Z"), "T", "F") + IIf(IsAlpha("1a"), "T", "F") + IIf(IsAlpha(""), "T", "F") + IIf(IsAlpha("_"), "T", "F") + IIf(IsAlpha(Chr(233)), "T", "F") + Chr(10))
   OutStd("isu=" + IIf(IsUpper("Ab"), "T", "F") + IIf(IsUpper("aB"), "T", "F") + IIf(IsUpper(""), "T", "F") + IIf(IsUpper("1"), "T", "F") + Chr(10))
   OutStd("isl=" + IIf(IsLower("aB"), "T", "F") + IIf(IsLower("Ab"), "T", "F") + IIf(IsLower(""), "T", "F") + IIf(IsLower("1"), "T", "F") + Chr(10))
   OutStd("sz1=[" + StrZero(5, 3) + "]" + Chr(10))
   OutStd("sz2=[" + StrZero(-5, 4) + "]" + Chr(10))
   OutStd("sz3=[" + StrZero(12345, 3) + "]" + Chr(10))
   OutStd("sz4=[" + StrZero(5) + "]" + Chr(10))
   OutStd("sz7=[" + StrZero(0, 4) + "]" + Chr(10))
   OutStd("sz8=[" + StrZero(-5, 1) + "]" + Chr(10))
   OutStd("sz9=[" + StrZero(7, 0) + "]" + Chr(10))
   OutStd("nulfill=" + Str(Asc(Left(PadC("ab", 5, ""), 1)), 3) + Str(Asc(Left(PadL("ab", 5, ""), 1)), 3) + Chr(10))
   OutStd("padl0=[" + PadL("ab", 0) + "][" + PadL("ab", -3) + "]" + Chr(10))
   owned()
   OutStd("mem=" + Str(hb_memcheck(), 3) + Chr(10))
return

function bump(c)
   c := c + "!"
return 2

procedure owned()
   local s := "abcdef", t := "", i, n := 0
   OutStd(PadC(Upper(s), 10, Lower("*")) + "|" + Chr(10))
   OutStd(Str(RAt(Lower("C"), Upper(s) + Lower(s)), 3) + Str(RAt(Left(s, 1), s), 3) + Chr(10))
   OutStd(Stuff(Upper(s), Len(s) - 3, 2, Lower("XY")) + "|" + Chr(10))
   OutStd(Stuff(s, bump(@s), 1, s) + "|" + s + Chr(10))
   s := "abcdef"
   OutStd(PadC(s, bump(@s) + 6, "-") + "|" + s + Chr(10))
   OutStd(IIf(IsDigit(Str(5, 1)), "T", "F") + IIf(IsAlpha(Upper(s)), "T", "F") + IIf(IsUpper(Lower(s)), "T", "F") + IIf(IsLower(Lower(s)), "T", "F") + Chr(10))
   OutStd(StrZero(n - 42, 6) + StrZero(Len(s)) + StrZero(123456, 3) + Chr(10))
   for i := 1 to 200
      t := PadC(Stuff(t, 1, 0, Chr(65 + i - Int(i / 26) * 26)), 30, ".")
      t := AllTrim(StrTran(t, ".", ""))
      if IsUpper(t) .and. RAt("A", t) > 0
         n++
      endif
   next
   OutStd(Str(n, 4) + Str(Len(t), 4) + " " + t + Chr(10))
return
