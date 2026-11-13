// HB-EXACT: calls as literal elements and as index (side-effect order); oracle = Harbour -gtstd binary
function two()
  ? 77
  return 2
function main()
  local a := {two(), 20, 30}
  ? a[two()]
  return nil
