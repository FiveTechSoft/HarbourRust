STATIC text := "abc"
PROCEDURE Main()
LOCAL result := Modify(text)
? result,text
ModifyRef(@text)
? text
RETURN
FUNCTION Modify(value)
value := value+"!"
RETURN value
FUNCTION ModifyRef(value)
value := value+"?"
RETURN NIL
