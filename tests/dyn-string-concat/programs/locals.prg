function main()
local d,s := "",t := ""
d := "ab"
? d+"cd", "xy"+d, d+"-"+d
s := "prefix"+d
t := s
? t
s := "prefix"+d
? s
d := d+"tail"
? d
s := s+d
? s
return nil
