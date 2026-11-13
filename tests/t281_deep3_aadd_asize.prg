function vi()
    ? "eval-i"
return 1
function vj()
    ? "eval-j"
return 1
function vv()
    ? "eval-v"
return 9
function work()
    local a := {{{1, 2}}, {{3}}}
    AAdd(a[vi()][vj()], vv())
    ? len(a[1][1])
    ? a[1][1][3]
    ? len(a)
    ? len(a[1])
    ASize(a[1][1], 1)
    ? len(a[1][1])
    ? a[1][1][1]
    ASize(a[2][1], 3)
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
