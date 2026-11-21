from common import *
a=setup(True);rows=[]
for name,source in json.loads(Path(__file__).with_name('cases.json').read_text()).items():
 w=a.output/name;w.mkdir();rows.append(dict(name=name,**exact(a,w,source)));print(name,'EXACT int/ext',flush=True)
finish(a,rows,'28own sources56exact int/ext Linux oracle pairs; every source rejected by baseline. Len evidence deferred until complete body, both statement orders. No runtime helper change.')
