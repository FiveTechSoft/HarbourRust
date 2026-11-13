// i64 is Copy: both variables stay usable; also prints a negative
function main()
    local a := 5
    local b := a
    ? a
    ? b
    ? a - 10
return nil
