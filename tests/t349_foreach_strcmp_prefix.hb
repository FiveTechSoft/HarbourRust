// xBase prefix rule (SET EXACT off): right-operand length, left NUL-padded (oracle hk37, same rule as b23).
function main()
    local h := {"abc" => 1}
    local k := hb_HKeys(h)
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
        endif
    next
return nil
