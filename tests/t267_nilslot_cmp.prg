function main()
    local a := {{1, 2}, {3, 4}}
    local b := {{}, {1}}
    ASize(a, 4)
    if a[3] = NIL
        ? "casilla es nil"
    endif
    if a[1] = NIL
        ? "MAL hijo nil"
    else
        ? "hijo no nil"
    endif
    if b[1] = NIL
        ? "MAL vacio nil"
    else
        ? "vacio no nil"
    endif
return
