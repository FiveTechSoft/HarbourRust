// neg: a codeblock cannot be passed to a user function in this increment
function f(x)
  return x + 1
function main()
  local b := {|x| x + 1}
  ? f(b)
  return nil
