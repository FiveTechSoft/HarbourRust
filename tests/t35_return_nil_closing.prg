// an early `return <value>` and a closing `return nil` agree: NIL is the
// tagged i64 sentinel (probe n1c), so both are i64 returns. Harbour allows
// the mix; the old rejection treated `return nil` as void.
function f(x)
    if x > 0
        return 5
    endif
return nil
function main()
    ? f(1)
    ? f(0)
return nil
