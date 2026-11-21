from common import *
a=setup(True);rows=[]
for name,source in json.loads(Path(__file__).with_name('cases.json').read_text()).items():
 w=a.output/name;w.mkdir();rows.append(dict(name=name,**exact(a,w,source)));print(name,'EXACT int/ext',flush=True)
finish(a,rows,'19own sources38exact Linux int/ext pairs,fixed fixture-only environment keys. Includes INIT,binary name,UTF8,70KiB value,ownership,keyeffectonce andthrow. No private environment values queried.')
