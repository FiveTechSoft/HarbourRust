// t507 (posx): a NUMERIC casilla against a string literal is Harbour's
// BASE/1070 condition (hk139b: error dialog that hangs headless, no
// oracle) - a clean named exit 1 here, registered failure mode, NOT
// exact equivalence. Third branch of the mixed family: t504 covers
// casilla == int (hk142), t506 int == casilla (hk144), this one
// int-cell == string-literal (hk139b).
function main()
    local a := Array(2)
    a[1] := 1
    if a[1] == "hola"
        ? 1
    else
        ? 0
    endif
return nil
