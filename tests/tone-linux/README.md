# TONE Linux GTSTD redirected-output bounded increment, own MIT

Two numeric literals,finite duration0..182ticks. Existing original sound.prg
is the motivating source. Native helper has real gettimeofday BEL cadence
and CLOCK_MONOTONIC deadline in20ms select slices. Literal frequency does
not synthesize audio:the measured redirected GTSTD backend writes BEL.
NonTTY only,TCGETS success is a named runtime boundary. Clock/select failure
also named limit,not Harbour failure equivalence. Threads/macros/platforms
outside ordinaryLinux excluded. Noarg,other tags,dynamic arguments remain
compile limits,despite oracle broader behavior. No ownership/model changes.

Research shows strict>500ms BEL cooldown,not one BEL per call. Original's
three9.1tick calls emit2BEL under ideal virtual20ms slices,but usually3live
because actual waits overshoot. Controlled source parity must inject BOTH
monotonic and realtime/gettimeofday consistently and use identical TZ.
First native harness omitted realtime epoch and failed timestamps;fixed UTC
harness matches full original triple. This does not establish live timing
byte exactness or audio pitch parity. 90controlled triples in5modes pass,including intact original and measured
duration boundaries.18limits,3netzero,Rust118,Python64+2skip,frontier30/701,
original285exact55zero2knownDELTA2,errors69,canary12. Linux1184internal
exact plus m1-values external exact. m1-values internal exceeds90seconds
in baseline AND current compiler despite byte-identical assembly;NOT counted
as internalPASS. Census1041/64,only sound newly admitted. Independent build
not yet repeated. FullLLVM/perf not repeated. fakeclock.c/fake-syscall.s are
own test injection sources,not production runtime.
