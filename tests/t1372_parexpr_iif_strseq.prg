// pos: inline IIF over comma sequences, including rodata string
// sequences (parexpr's ("some", "text", ...) shapes).
function main()
    ? IF( (.F.,0,.T.), ("some", "text", "IF Working"), ("some", "text", "Broken") )
    ? IF( (.T.,1,.F.), ("some", "text", "Broken"), ("some", "text", "IF Working") )
    ? IF( (.T. .OR. .F.), IF( .T., "Working", "Broken" ), IF( .F., "Broken", "Working" ) )
    return nil
