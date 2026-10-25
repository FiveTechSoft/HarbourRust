// neg: codeblock capture of a function local (Harbour accepts, probe c3 - next increment)
function main()
  local n := 10
  local b := {|x| x + n}
  ? eval(b, 1)
  return nil
