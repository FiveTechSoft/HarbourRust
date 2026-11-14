function pick(c)
    local x1 := "aa" + "1"
    local x2 := "bb" + "2"
    local r := iif(c > 1, x1, x2)
return r

function main()
    ? pick(2)
return nil
