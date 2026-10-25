function adder(n)
  return {|x| x + n}
function main()
  local b := adder(10)
  ? eval(b, 5)
  return nil
