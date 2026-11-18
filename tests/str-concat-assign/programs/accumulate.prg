function main()
 local c := "Total: ", i, b, s := "x"
 local w := "abc"
 for i := 1 to 3
    c += Str(i, 2) + ","
 next
 ? c, Len(c)
 c := "reset"
 ? c
 c += ""
 ? c
 s := s + s
 s += s
 ? s, Len(s)
 b := "abcd!"
 w += "d"
 ? b, w
 w := Upper(w) + w
 ? w
 ? g(c)
 ? h()
return nil
function g(p)
 local r := "<"
 r += p
 r := r + ">"
return r
function h()
 local t := "A"
 do while Len(t) < 5
    t += "B"
 enddo
 if Len(t) == 5
    t := t + "C"
 else
    t := "no"
 endif
return t
