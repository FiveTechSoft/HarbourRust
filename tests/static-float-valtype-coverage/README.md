# ValType float coverage supplement

Original MIT. Tests-only on f6a172fa, same compiler cd134611.
Repeated155/155 previous float triples: local50,store65,read20,extra20.
Five new exact triples (method-local STATIC float ValType,5modes). Two limits
(local STATIC float captured by block ValType and passed by @ before ValType)
reject through existing generic capture/persistent guards. Source declares n
INSIDE Main in both limits; there is no module declaration. These do not
establish a new guard, only retained rejection. No independent repetition of
this supplement; primary compiler only. Old local-static limit in store runner
is expected rc0, not a failure masked as green. No full manifest/perf/FullLLVM,
no fatal unwind or original initexit closure. No implementation code changed.
