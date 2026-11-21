from common import *
a=setup(True);rows=[]
for name,source in json.loads(Path(__file__).with_name('cases.json').read_text()).items():
 w=a.output/name;w.mkdir();rows.append(dict(name=name,**exact(a,w,source)));print(name,'EXACT int/ext',flush=True)
finish(a,rows,'8own sources16exact int/ext Linux oracle pairs;baseline rejects all. Zeroarg empty-string OS separator,owned retention/cache-reuse,return,concat,nested,comparison,INIT. No filesystem effects.')
