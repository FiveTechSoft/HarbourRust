// HB-EXACT values (write order probe m7): a[i][j] := v and a[i,j] := v
function main()
local a := {{1, 2}, {3, 4}}
a[1][2] := 9
a[2, 1] := 7
? a[1][1]
? a[1][2]
? a[2][1]
? a[2][2]
return nil
