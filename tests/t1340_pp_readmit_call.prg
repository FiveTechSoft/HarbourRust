PROCEDURE Main()
#define CLASS Test
#xtranslate ID(<x>) => <x>
#xtranslate JOIN <!a!> <b> => <a>_<b>
LOCAL Test_New := 7
? ID(JOIN CLASS New)
RETURN
