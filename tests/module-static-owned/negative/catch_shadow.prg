#ifdef HARBOUR_ORACLE
#define TRY BEGIN SEQUENCE
#define CATCH RECOVER USING
#define ENDTRY END SEQUENCE
#else
#define ENDTRY END
#endif
STATIC text := "abc"
PROCEDURE Main()
TRY
Break("oops")
CATCH text
? text
ENDTRY
RETURN
