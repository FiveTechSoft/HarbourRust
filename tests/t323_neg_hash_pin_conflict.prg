// A parameter pinned both as an array of strings (p[1] := "x") and as a
// hash (p["k"] := 1) cannot compile: the body error surfaces first
// (pin failures fall back to i64 so the body can name the misuse).
function f(p)
    p[1] := "x"
    p["k"] := 1
return 0
function main()
    local h := {"a" => 1}
    ? f(h)
return nil
