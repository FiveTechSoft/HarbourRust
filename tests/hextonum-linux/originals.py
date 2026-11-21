from common import *
a=setup(True);assert a.harbour_core;rows=[]
rel='contrib/hbnf/hex2dec.prg';original=a.harbour_core/rel;before=h(original);w=a.output/'hex2dec';w.mkdir();a.oracle_include=[original.parent,a.harbour_core/'include']
source='#include "hex2dec.prg"\nfunction Main()\n? ft_Hex2Dec("1aF"),ft_Hex2Dec("12x"),ft_Hex2Dec("FFFFFFFFFFFFFFFF"),ft_Hex2Dec("12"+Chr(0)+"FF"),ft_Hex2Dec("")\nreturn nil\n'
row=exact(a,w,source,extra=['-I',str(original.parent),'-I',str(a.harbour_core/'include')]);assert h(original)==before;rows.append(dict(name='hex2dec',original=rel,original_sha256=before,**row))
finish(a,rows,'1own include driver of unchanged original hex2dec library,2exact int/ext oracle pairs. Baseline rejects. No external body copied into product/tests;not standalone acceptance.')
