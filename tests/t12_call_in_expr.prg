// a call nested inside an arithmetic expression: keeping the lhs with a
// plain push would break Win64 16-byte stack alignment at the nested call
function valor()
    ? "en valor"
    return 40
function main()
    ? 1 + valor()
    ? valor() + 1
    ? 2 * valor()
return nil
