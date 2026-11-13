// QOut evaluates ALL items before printing (side effects first), then newline + items (probe q3)
function f(n)
  ? "f", n
  return n * 2
function main()
  ? f(1), f(2)
  return nil
