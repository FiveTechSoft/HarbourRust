from common import *
a=setup(True);rows=[]
for name,source in json.loads(Path(__file__).with_name('cases.json').read_text()).items():
 w=a.output/name;w.mkdir();rows.append(dict(name=name,**exact(a,w,source)));print(name,'EXACT int/ext',flush=True)
finish(a,rows,'40own sources80exact int/ext Linux oracle pairs;baseline rejects all. Strict parse,space-only prefix,NUL terminator,invalid resets0,modulo2^64,UTF8bad,70KiB,borrowed input,effects andthrow.')
