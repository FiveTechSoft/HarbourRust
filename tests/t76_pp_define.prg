// the preprocessor runs inside hbc: object-like define used as a bound
#define LIMIT 5
function main()
    local s := 0
    for i := 1 to LIMIT
        s := s + i
    next
    ? s
    return nil
