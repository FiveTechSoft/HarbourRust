// ...but the exit path still counts as moved after the loop
function main()
    local a := "hola"
    while 1 < 2
        local b := a
        ? b
        exit
    enddo
    ? a
return nil
