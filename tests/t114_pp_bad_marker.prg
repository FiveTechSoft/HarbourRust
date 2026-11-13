// negative: <{b}> is not a valid match marker (Harbour: E0010, probe b41);
// same for <"x"> and <#x>.
#command RUN <{b}> => ? 1
function main()
    RUN 1
    return nil
