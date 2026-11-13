function main()
    // Oracle anadd: AAdd on a 3-element child appends at index 4.
    local a := Array(2, 3)
    AAdd(a[1], 7)
    ? len(a[1])
    ? a[1][4]
    ? a[1][3]
return
