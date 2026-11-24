// HB-EXACT: START once before TO; TO repeats before every comparison.
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
