from common import *
a=setup(True);rows=[]
for name,source in json.loads(Path(__file__).with_name('cases.json').read_text()).items():
 w=a.output/name;w.mkdir();rows.append(dict(name=name,**exact(a,w,source)));print(name,'EXACT int/ext',flush=True)
finish(a,rows,'39own sources78exact int/ext Linux oracle pairs;baseline rejects all. Counted bytes,NUL,all256bytes,UTF8,70KiB,base64padding/lengthboundaries,no wrapping,ownership,effects andthrow.')
