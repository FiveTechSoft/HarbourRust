function make()
    return {|n| n + 1}
function main()
    local x := make()
    local y := make()
    ? x == x
    ? x == y
    ? make() == make()
return nil
