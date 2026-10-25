// negative: text after the `;` (even a comment) is a syntax error in
// Harbour (probe b39c: E0030); we reject the stray `;` in the lexer.
function main()
    local a := 1 + ; comment after semi
        2
    return nil
