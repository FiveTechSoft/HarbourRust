function main()
 local a := {}, b := {|x| x > 2}, c := {|x, i| x == 7 .and. i > 2}
 AAdd(a, 1)
 AAdd(a, 7)
 AAdd(a, 3)
 AAdd(a, 7)
 ? Eval(b, 3), Eval(b, 1), Eval({|| .t.})
 ? AScan(a, {|x| x > 2}), AScan(a, {|x| x > 100})
 ? AScan(a, c), AScan(a, {|x, i| i == 4})
 ? AScan(a, b), AScan(a, {|x| !(x < 5)})
 if Eval(b, 5)
    ? "yes"
 endif
return nil
