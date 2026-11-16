#ifdef HARBOUR_ORACLE
#define TRY BEGIN SEQUENCE
#define CATCH RECOVER USING
#define ENDTRY END SEQUENCE
#else
#define ENDTRY END
#endif
STATIC text := "before"
PROCEDURE Main()
LOCAL err
TRY
ChangeAndFail()
CATCH err
? err,text
ENDTRY
RETURN
FUNCTION ChangeAndFail()
text := "after"
Break("expected")
RETURN NIL
