procedure main()
    local k := hb_HKeys({"abc" => 1})
    local c := ""
    for each c in k
        if c = "a"
            ? "corta-der-igual"
        else
            ? "corta-der-distinta"
        endif
        if c = "abcd"
            ? "larga-der-igual"
        else
            ? "larga-der-distinta"
        endif
        if c = "abc"
            ? "exacta-igual"
        else
            ? "exacta-distinta"
        endif
    next
return
