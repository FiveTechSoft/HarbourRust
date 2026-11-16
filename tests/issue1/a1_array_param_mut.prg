function main()
 local v := {0,0}
 f(1, v)
 ? v[1]
return nil
function f(n, v)
 v[1] := v[1] + n
return nil
