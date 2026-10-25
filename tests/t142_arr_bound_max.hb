// DIVERGE-FAILMODE: i64::MAX index -> bound error + exit 1; Harbour opens its interactive dialog and hangs (probe a1/a2)
function main()
  local a := {10, 20}
  local big := 9223372036854775807
  ? a[big]
  return nil
