// I3 permanent regression, reused existing compiler contract; not a new Harbour parity claim.
// returning a dynamic array moves ownership to the caller
function mk()
  local a := {}
  AAdd(a, 7)
  AAdd(a, 8)
  return a
function main()
  local b := mk()
  ? b[1]
  ? len(b)
  return nil
