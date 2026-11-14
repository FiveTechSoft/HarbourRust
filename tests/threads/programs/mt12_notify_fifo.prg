procedure Main()
   local mtx := hb_mutexCreate()
   local a, b
   hb_mutexNotify(mtx, "first")
   hb_mutexNotify(mtx, "second")
   hb_mutexSubscribe(mtx, 1, @a)
   hb_mutexSubscribe(mtx, 1, @b)
   ? "order", a, b
return
