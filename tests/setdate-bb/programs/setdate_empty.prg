procedure main()
local d := CToD("")
SET DATE AMERICAN
? "[" + DToC(d) + "]", "[" + DToS(d) + "]"
SET DATE ANSI
? "[" + DToC(d) + "]"
SET DATE BRITISH
? "[" + DToC(d) + "]"
SET DATE GERMAN
? "[" + DToC(d) + "]"
SET DATE ITALIAN
? "[" + DToC(d) + "]"
SET DATE USA
? "[" + DToC(d) + "]"
SET DATE JAPANESE
? "[" + DToC(d) + "]"
SET CENTURY ON
? "[" + DToC(d) + "]"
SET DATE AMERICAN
? "[" + DToC(d) + "]", "[" + DToS(d) + "]"
SET DATE ANSI
? "[" + DToC(d) + "]"
SET DATE GERMAN
? "[" + DToC(d) + "]"
? d, "|"
return
