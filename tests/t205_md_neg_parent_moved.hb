// neg: parent moved inside the index expression
function consume(a)
  return len(a)
function main()
  local a := {}
  AAdd(a, 1)
  a[consume(a)] := 1
  return nil
