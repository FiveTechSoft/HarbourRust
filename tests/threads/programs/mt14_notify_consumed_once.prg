procedure Main()
   local mtx := hb_mutexCreate()
   local v1, v2
   hb_mutexNotify(mtx, "once")
   ? "sub1", hb_mutexSubscribe(mtx, 0.2, @v1), v1
   ? "sub2", hb_mutexSubscribe(mtx, 0.2, @v2), v2
return
