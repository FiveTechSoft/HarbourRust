// guard: more than 16384 simultaneously LIVE allocations overflow the
// instrument registry and surface as OOM (harness limit of the
// instrumented build only; normal builds carry no registry).
function main()
  local d := {}
  for i := 1 to 17000
    local c := {}
    AAdd(c, i)
    AAdd(d, c)
  next
  ? len(d)
  return nil
