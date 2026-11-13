// neg-MODEL: moves inside one expression
// Harbour accepts (no ownership): prints "0".
// Our Rust ownership rejects the second use of the moved String.
function take(s)
  if s = "zzz"
    return 1
  endif
  return 0
function main()
  local v := "abc"
  ? take(v) + take(v)
  return nil
