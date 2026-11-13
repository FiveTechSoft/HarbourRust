// advancing the counter past i64::MAX must end the loop, not wrap it
// (before the fix this ran ~2^64 iterations)
function main()
    for i := 9223372036854775806 to 9223372036854775807
        ? i
    next
    ? "fin"
    for j := 9223372036854775806 to 9223372036854775807 step 2
        ? j
    next
    ? "fin2"
return nil
