// HB-EXACT: whole-array reassignment with the same size; oracle = Harbour -gtstd binary
function main()
  local a := {1, 2}
  a := {9, 8}
  ? a[1], a[2]
  return nil
