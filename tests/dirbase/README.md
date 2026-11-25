# Startup hb_DirBase short-path Linux profile

Own MIT helper based on external Harbour executable observations. Captures
startup cwd/argv0/PATH before Main. No /proc/self/exe or realpath substitution:
symlink directory preserved,relative argv prepends physical cwd,one leading
./ stripped,remaining ../,./ and doubled separators preserved. Bare filename
searches nonempty PATH entries,accepts regular non-executable file,excludes
directory. Returns independent owned copy on each call,base never mutated.

check.py95:90fresh Harbour-exact triples in5Linuxmodes plus5named runtime
long-path limits. Empty/missing argv/PATH yield empty. Short path profile:
startup cwd at most262bytes and combined candidate at most262bytes. Larger
paths fail named rc1,not speculative replication of Harbour's irregular
263-byte truncation edge. No general long-path or failure parity claim.
Noargs only,ordinary Linux,no threads/macros/other backend. Allocation/cache
startup handling has no persistent heap owner,only fixed process storage.

Intact diskspac reaches hb_DiskSpace typed-path-vs-Dyn rejection,no closure.
