function main()
  local n := 1
  local get := {|| n}
  local set := {|x| n := x}
  eval(set, 7)
  ? eval(get)
  return nil
