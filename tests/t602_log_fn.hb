// Logicals as function parameters and returns (oracle hk204). The identity
// function shapes its body through `.AND. .T.` because body-only inference
// cannot type a bare returned parameter (registered inference limit);
// Harbour's behaviour - passing and returning logicals - is what is tested.
function idlog(x)
    return x .AND. .T.
function not2(x)
    return .NOT. x
function main()
    ? idlog(.T.)
    ? idlog(.F.)
    ? not2(.T.)
return nil
