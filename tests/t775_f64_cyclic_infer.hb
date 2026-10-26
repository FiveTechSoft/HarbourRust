function f(n)
   if n <= 0
      return 0.5
   endif
   return g(n - 1) + 1.0
function g(n)
   return f(n)
function main()
   ? f(2)
   return nil
