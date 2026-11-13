// String parameters are owned by the callee: a rodata argument (literal
// or literal-initialized local) is COPIED at the call boundary; the
// callee frees its copy. Balance 0 across both calls.
function show(s)
    if s = "hi"
        ? s
    endif
return 0
function wrap()
    ? show("hi")
    local v := "yo"
    ? show(v)
    v := "back"
    ? v
return 0
function main()
    ? wrap()
    ? hb_memcheck()
return nil
