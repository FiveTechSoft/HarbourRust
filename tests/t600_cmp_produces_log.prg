// t600: comparisons PRODUCE logicals (oracle hk198)
function main()
    local x := ( 1 == 1 )
    local y := ( 1 == 2 )
    ? x
    ? y
    ? ValType( x )
    ? x .AND. y
    ? x .OR. y
    ? 3 > 2
return nil
