function main()
local t := hb_SToT("20261123101530999")
? t
set date british
set century on
? t,hb_TToD(t),hb_SToT("")
set date ansi
set century off
? t
OutStd("[",t,"]")
OutErr("[",t,"]")
return nil
