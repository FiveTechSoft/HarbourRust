// Loop register promotion (src/loopreg.rs): EXIT, LOOP, nested FOR,
// WHILE, RETURN from inside a loop and a negative STEP, all with integer
// locals the pass keeps in registers; values must match the frame path.
function main()
 local i := 0, j := 0, s := 0, n := 0, k := 7
 for i := 1 to 100
    s := s + i * k
    if s > 2000
       exit
    endif
 next
 ? i, s
 s := 0
 for i := 1 to 10
    for j := 1 to 10
       if j == i
          loop
       endif
       s := s + j - i
    next
    n := n + j
 next
 ? i, j, s, n
 s := 0
 i := 0
 while i < 50
    i := i + 3
    if i % 2 == 0
       loop
    endif
    s := s - i
 enddo
 ? i, s
 ? early(5), early(500)
 s := 0
 for i := 10 to 1 step -2
    s := s * 3 + i
 next
 ? i, s
return nil

function early(m)
 local i, t := 0
 for i := 1 to 1000
    t := t + i
    if t > m
       return t * 100 + i
    endif
 next
return -1
