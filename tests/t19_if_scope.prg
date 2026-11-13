// branch locals are scoped to the branch: z does not exist after endif
function main()
    if 1 = 1
        local z := 40
        ? z
    endif
    ? z
return nil
