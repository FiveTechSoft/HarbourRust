// NOTE (arrays increment, t126+): '{' is now grammar (array literals), so this
// line is rejected by the PARSER (trailing tokens), not the lexer (U+007B).
// The injection premise stands: the construct is still rejected.
function main()
    local x := unsafe { 1 }
return nil
