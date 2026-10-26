// Self-recursion with a re-lent @ borrow (oracle hk255: Harbour prints
// 0, we print 0). Before order-independent inference this file was a
// neg test only because the recursive call hit the define-before-use
// rejection; the reborrow chain itself is sound: each frame's borrow
// ends before the inner call's begins.
function countdown( n )
   if n > 0
      n := n - 1
      countdown( @n )
   endif
   return
function main()
   local x := 3
   countdown( @x )
   ? x
   return
