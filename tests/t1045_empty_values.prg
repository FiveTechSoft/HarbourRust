procedure main()
local a := {}, h := {"x"=>1}, b := {|n| n+1}, s := "abc"
? Empty(0), Empty(1), Empty(-1), Empty(0.0), Empty(-0.0), Empty(0.00001)
? Empty(.F.), Empty(.T.), Empty(NIL), Empty(b)
? Empty(""), Empty(" "), Empty(Chr(9)), Empty(Chr(10)), Empty(Chr(13))
? Empty(Chr(11)), Empty(Chr(12)), Empty(Chr(0)), Empty(Chr(160))
? Empty(" " + Chr(9) + Chr(10) + Chr(13)), Empty("  a  ")
? Empty(a), Empty(h), Empty(s), Len(s)
? Empty(AllTrim("   "))
return
