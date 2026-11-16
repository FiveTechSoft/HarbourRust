function main()
 local v := {0,0}
 ? f(5, v)
 ? f(7, v)
 ? v[1], v[2]
return nil
function f(n, v)
 local c := "00"
 do case
 case n <= 5
    v[1] := v[1] + n
    c := "A"
 otherwise
    v[2] := v[2] + n
    c := "B"
 endcase
return c
