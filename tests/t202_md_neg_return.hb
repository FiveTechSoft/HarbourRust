// pos (iteration 21): returning an array of arrays (oracle pr3)
function mk()
  local a := {{1}}
  return a
function main()
  local b := mk()
  ? len(b)
  return nil
