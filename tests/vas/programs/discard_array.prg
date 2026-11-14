// I3 permanent regression, reused existing compiler contract; not a new Harbour parity claim.
// Discarding an array return is legal in Harbour (oracle hk256: the
// callee runs for effect, the returned block is freed right after the
// call). FLIPPED neg -> pos in 63q: the old premise was the rejection
// itself. Prints nothing; the leak check lives in t699.
function mk()
   return Array( 2 )

function main()
   mk()
   return
