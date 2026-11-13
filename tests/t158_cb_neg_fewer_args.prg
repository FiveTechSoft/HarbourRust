// neg: fewer eval arguments than parameters (Harbour fails at runtime - probe c8; we reject at compile time)
function main()
  local b := {|x, y| x + y}
  ? eval(b, 5)
  return nil
