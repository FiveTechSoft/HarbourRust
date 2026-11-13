// QOut byte semantics: bare ? = newline; ints pad to 10; >10 no pad; negatives (probes b51-b57, q1)
function main()
  ?
  ? 1
  ? 12345678901
  ? -7
  return nil
