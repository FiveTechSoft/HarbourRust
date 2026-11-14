procedure Main()
   local mtx := hb_mutexCreate()
   local val
   hb_mutexNotifyAll(mtx, "bcast")
   ? "sub-after-notifyall", hb_mutexSubscribe(mtx, 0.2, @val)
   ? "val", val
return
