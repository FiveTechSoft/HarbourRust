function main()
local d:=ctod("")
set date to german
set epoch to 1950
d:=ctod("01.02.49")
? d, year(d)
d:=ctod("01.02.50")
? d, year(d)
d:=ctod("01.02.00")
? year(d)
d:=ctod("01.02.0049")
? year(d)
d:=ctod("01.02.049")
? year(d)
d:=ctod("01.02.0050")
? year(d)
set epoch to 2000
d:=ctod("01.02.99")
? year(d)
d:=ctod("01.02.00")
? year(d)
set date to ansi
d:=ctod("49.02.01")
? d, year(d)
set date to japanese
d:=ctod("2005/03/04")
? d, month(d), day(d)
set date to american
d:=ctod("04/05/06")
? d, year(d)
d:=ctod("04/05/1906")
? d
return nil
