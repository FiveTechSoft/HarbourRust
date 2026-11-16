function main()
 local v := {0,0}
 ? f(5, v)
 ? v[1]
return nil
function f(n, v)
 local c := "00"
 v[1] := v[1] + n
 c := "30"
return c
