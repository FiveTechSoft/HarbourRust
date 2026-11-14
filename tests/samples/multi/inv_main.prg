// demo multi-module: main program (concatenated build)
function main()
    local skus := SeedSkus()
    local qtys := SeedQtys()
    local counts := { "OK" => 0, "OUT" => 0 }
    local summary := PrintItems(skus, qtys)
    counts["OK"] := summary[1]
    counts["OUT"] := summary[2]
    ? counts["OK"], counts["OUT"]
    ? NextId(), NextId(), NextId()
    return nil
