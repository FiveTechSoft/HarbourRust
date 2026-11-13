// DIVERGE-FAILMODE: i64::MIN index -> bound error + exit 1; Harbour hangs on its dialog
function main()
  local a := {10, 20}
  local neg := 0 - 9223372036854775807 - 1
  ? a[neg]
  return nil
