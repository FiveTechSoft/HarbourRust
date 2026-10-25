function main()
  local n := 1
  local b := {|| n}
  n := 99
  ? eval(b)
  return nil
