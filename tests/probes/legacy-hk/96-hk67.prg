// order of evaluation: indices first, value after (middle level AAdd)
function ni()
    ? "eval"
return 1
function vv()
    ? "val"
return {7, 8}
function main()
    local a := {{{1, 2}}}
    AAdd(a[ni()], vv())
    ? len(a[1])
return nil
