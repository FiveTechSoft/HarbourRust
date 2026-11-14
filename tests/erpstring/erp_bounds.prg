// Left/Right boundary semantics: count 0 or negative is the empty string,
// a count beyond the length clamps to the whole string.
function main()
   ? len(left("abcdef", 0))
   ? len(left("abcdef", 0 - 3))
   ? len(left("abcdef", 99))
   ? left("abcdef", 4)
   ? len(right("abcdef", 0))
   ? len(right("abcdef", 0 - 1))
   ? len(right("abcdef", 99))
   ? right("abcdef", 4)
return nil
