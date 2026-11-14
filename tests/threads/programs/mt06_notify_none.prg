procedure Main()
   local mtx := hb_mutexCreate()
   local val
   hb_mutexNotify(mtx, "lost")
   ? "sub-after-notify", hb_mutexSubscribe(mtx, 0.2, @val)
   ? "val", val
return
