// branch-local dynamic arrays: freed at the function epilogue; slot zero-init keeps untaken branches safe
function main()
  local a := {}
  AAdd(a, 1)
  if 1 = 1
    local b := {}
    AAdd(b, 9)
    ? b[1]
  else
    local c := {}
    AAdd(c, 8)
    ? c[1]
  endif
  ? a[1]
  return nil
