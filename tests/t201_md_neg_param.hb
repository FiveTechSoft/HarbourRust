// pos (iteration 21): array of arrays as a function parameter (oracle pr1)
function f(a)
  return len(a[1])
function main()
  local a := {{1}}
  ? f(a)
  return nil
