// At semantics: case-sensitive 1-based position, 0 when not found.
function main()
   ? at("c", "abcabc")
   ? at("C", "abcabc")
   ? at("zz", "abc")
   ? at("a", "abc")
return nil
