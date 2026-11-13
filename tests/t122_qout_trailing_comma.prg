// negative: trailing comma. Harbour ACCEPTS it as a NIL item (probe q4,
// prints "         1 NIL"); the subset has no NIL value to print, so it
// rejects - registered output-model difference.
function main()
    ? 1,
    return nil
