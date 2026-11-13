// A whole array/hash prints empty in Harbour, but this increment only
// accepts a VARIABLE in that position: a constructing temporary must
// not be silently skipped (parent rule: the static suffix analysis
// never drops operand effects).
function main()
    ? {"a" => 1}
    return nil
