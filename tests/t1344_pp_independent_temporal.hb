PROCEDURE Main()
#define VALUE 7
#xtranslate JOIN <!a!> <!b!> => <a>_<b>
#xcommand BOTH => ? JOIN Test New,VALUE;#define VALUE 8;? JOIN Test New,VALUE
LOCAL Test_New := 1
BOTH
RETURN
