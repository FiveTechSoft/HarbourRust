procedure Main()
? "literal integer",1
? "Val1",Val("1")
? "Val10width",Val("         1")
? "Valfraction",Val(" 1.20")
? "Valsuffix",Val("1.2xyz")
? "Valinvalid-dot",Val("abc.def")
? "ValI64exact",Val("9007199254740993")
? "I64equality",Val("9007199254740993")=9007199254740993
? "float-equality",Val("9007199254740993")=9007199254740992.0
? "Valexp",Val("1e3")
? "Valhex",Val("0x10")
? "Valempty",Val("")
? "Valspaces",Val("   ")
? "Valminus",Val("-0")
? "Valmax",Val("9223372036854775807")
? "Valoverflow",Val("9223372036854775808")
? "Valmin",Val("-9223372036854775808")
? "Valleadingtab",Val(Chr(9)+"12")
? "ValembeddedNUL",Val("12"+Chr(0)+"34")
return
