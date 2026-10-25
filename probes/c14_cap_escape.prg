function mk()
  local v := 42
  return {|| v}
function main()
  local b := mk()
  ? eval(b)
  return nil
