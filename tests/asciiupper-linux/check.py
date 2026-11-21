from common import *
a=setup(True);rows=[]
for name,source in json.loads(Path(__file__).with_name('cases.json').read_text()).items():
 w=a.output/name;w.mkdir();rows.append(dict(name=name,**exact(a,w,source)));print(name,'EXACT int/ext',flush=True)
finish(a,rows,'17own sources34exact int/ext Linux oracle pairs;baseline rejects all. Counted bytes,NUL,all256bytevalues,UTF8,70KiB,ownership,effects andthrow. ASCII a-z only,one typed string.')
