// neg-MODEL: use of moved value in later QOut item
// Harbour accepts (no ownership): prints "0 abc".
// Our Rust ownership rejects the second use of the moved String.
function take(s)
  if s = "zzz"
    return 1
  endif
  return 0
function main()
  local v := "abc"
  ? take(v), v
  return nil
