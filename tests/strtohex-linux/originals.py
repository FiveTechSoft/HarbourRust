from common import *
a=setup(True);assert a.harbour_core;rows=[]
rel='contrib/hbnf/byt2hex.prg';original=a.harbour_core/rel;before=h(original);w=a.output/'byt2hex';w.mkdir();a.oracle_include=[original.parent,a.harbour_core/'include']
source='#include "byt2hex.prg"\nfunction Main()\n? ft_Byt2Hex("A"),ft_Byt2Hex(Chr(0)),ft_Byt2Hex(Chr(255)),ft_Byt2Hex("abc"),ft_Byt2Hex("")\nreturn nil\n'
row=exact(a,w,source,extra=['-I',str(original.parent),'-I',str(a.harbour_core/'include')]);assert h(original)==before;rows.append(dict(name='byt2hex',original=rel,original_sha256=before,**row))
finish(a,rows,'1own include driver of unchanged original byt2hex library,2exact int/ext oracle pairs. Baseline rejects. No external body copied into product/tests;not standalone acceptance.')
