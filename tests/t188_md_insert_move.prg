// OURS-ONLY ownership: AAdd(a, b) MOVES b into the parent; deep free, balance 0 across the function boundary (Harbour shares - probe m4 - MODEL divergence)
function work()
  local a := {{1, 2}, {3, 4}}
  local b := {}
  AAdd(b, 7)
  AAdd(b, 8)
  AAdd(a, b)
  return len(a) * 100 + a[3][2]
function main()
  ? work()
  ? hb_memcheck()
  return nil
