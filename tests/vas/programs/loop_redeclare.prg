// I3 permanent regression, reused existing compiler contract; not a new Harbour parity claim.
// a local re-declared each iteration frees the previous value
function main()
  for i := 1 to 3
    local t := {}
    AAdd(t, i * 10)
    ? t[1]
  next
  return nil
