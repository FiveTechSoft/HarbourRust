// line continuation with `;` (probes b39/b39b/b39e): the semicolon must be
// the last non-whitespace character OUTSIDE any string; chains work.
function main()
    local a := 1 + ;
        2
    local s := "a;b"
    ? a
    ? s
    ? 1 + ;
    2 + ;
    3
    return nil
