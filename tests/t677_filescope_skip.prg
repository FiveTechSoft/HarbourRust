// File-scope MEMVAR lines are accepted and ignored (oracle hk247b) -
// they create no storage (t685 proves a reference still fails). REQUEST
// is honored only for a function defined in this same file: the subset
// has no module linking, so any other REQUEST would silently skip a
// link/init effect (oracle hk250a; t686 covers the rejection).
MEMVAR m_x
REQUEST helper
? "body"

function helper()
   return 1
