function main()
local a := { 9223372036854775807, 7 }
a[2] *= 2
a[1] -= 1
a[1] += 2
? a[1]
return nil
