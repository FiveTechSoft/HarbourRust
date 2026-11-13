// neg: a MEMVAR declaration relaxes compile-time name resolution only;
// it creates no storage, so a memvar reference still fails by name.
MEMVAR m_y
m_y := 1
