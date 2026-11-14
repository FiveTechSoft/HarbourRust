// Int/Abs accept float-typed parameters: the float use (x * 1.5 / x * 2.0)
// and the Int/Abs use must not conflict in parameter typing.
function f(x)
   x := x * 1.5
   return int(x)

function g(x)
   x := x * 2.0
   return abs(x)

function main()
   ? f(7)
   ? g(0 - 3)
return nil
