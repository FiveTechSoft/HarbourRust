function main()
? f("abc", .t.)
? f("7", .f.)
return nil
function f(p, early)
if early
   return p + "!"
endif
p := val(p)
return p + 1
