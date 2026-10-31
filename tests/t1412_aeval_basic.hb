// pos: AEval(a, block) statement over an int array - ascending loop,
// block evaluated with (element, index); oracle arreval shape.
function main()
   local a := { 100, 200, 300 }
   AEval( a, {| nValue, nIndex | QOut( nValue, nIndex ) } )
   return nil
