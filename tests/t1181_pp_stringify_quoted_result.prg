// EXPECT: #42
// EXPECT: A#42Z
// EXPECT: #42
// EXPECT: 42
#command TEST <x> => ? "#<x>" ; ? "A#<x>Z" ; ? '#<x>' ; ? #<x>
PROCEDURE Main()
TEST 42
RETURN
