// HB-EXACT: for evaluates START before END (Harbour probe c11, same as Rust range order)
function f()
  ? 1
  return 1
function g()
  ? 2
  return 2
function main()
for i := f() to g()
  ? i
next
return nil
