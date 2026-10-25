// HB-EXACT: a[i] := v evaluates the VALUE first, then the index (Harbour probe adv2, same as Rust); oracle = Harbour -gtstd binary
function idx()
  ? 1
  return 2
function give()
  ? 2
  return 99
function main()
  local a := {10, 20, 30}
  a[idx()] := give()
  ? a[2]
  return nil
