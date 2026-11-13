// neg: a parameter both omitted (NIL fill) and float-pinned by its body
// needs a Dyn float payload - the representation decision is pending.
function g(x)
    return x * 2.5
function main()
    ? g(2)
    ? g()
    return nil
