// ASize applies to dynamic arrays, not to a hash itself: named compile
// error. (ASize on the ARRAY that hb_HKeys returns works since the
// ASize increment: shrink frees copies, grow is a clean runtime error.)
function main()
    local h := {=>}
    h["a"] := 1
    ASize(h, 5)
return nil
