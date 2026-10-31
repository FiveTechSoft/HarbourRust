// pos: AEval bounds per oracle ae2/ae4 - start 3; start 2 count 2;
// start beyond len -> none; start 0 -> from 1; count 0 -> none;
// negative start -> none; negative count -> to the end.
function main()
   local a := { 10, 20, 30, 40, 50 }
   ? "start3:"
   AEval( a, {|x,i| QOut(x,i) }, 3 )
   ? "start2count2:"
   AEval( a, {|x,i| QOut(x,i) }, 2, 2 )
   ? "start9:"
   AEval( a, {|x,i| QOut(x,i) }, 9 )
   ? "start0:"
   AEval( a, {|x,i| QOut(x,i) }, 0 )
   ? "count0:"
   AEval( a, {|x,i| QOut(x,i) }, 1, 0 )
   ? "negstart:"
   AEval( a, {|x,i| QOut(x,i) }, -2 )
   ? "negcount:"
   AEval( a, {|x,i| QOut(x,i) }, 2, -1 )
   ? "end"
   return nil
