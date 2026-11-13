// neg-MODEL: both value and index consume the same String -> use-after-move rejected (ownership contract)
function take(s)
  if s = "zzz"
    return 1
  endif
  return 0
function main()
  local a := {10, 20}
  local v := "ab"
  a[take(v)] := take(v)
  return nil
