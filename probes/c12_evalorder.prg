function mk()
  ? 1
  return {|x| x + 1}
function arg()
  ? 2
  return 5
function main()
  ? eval(mk(), arg())
  return nil
