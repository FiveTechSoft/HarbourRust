function vi()
    ? "eval-i"
return 2
function vj()
    ? "eval-j"
return 1
function vn()
    ? "eval-n"
return 3
function work()
    local a := {{{1, 2}}, {{3}}}
    ASize(a[vi()][vj()], vn())
    ? len(a[2][1])
    if a[2][1][2] = NIL
        ? 1
    else
        ? 0
    endif
return 0
function main()
    ? work()
    ? hb_memcheck()
return
