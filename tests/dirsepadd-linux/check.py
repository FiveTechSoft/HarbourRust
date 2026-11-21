from common import *
a=setup(True);rows=[]
for name,source in json.loads(Path(__file__).with_name('cases.json').read_text()).items():
 w=a.output/name;w.mkdir();rows.append(dict(name=name,**exact(a,w,source)));print(name,'EXACT int/ext',flush=True)
finish(a,rows,'16own sources32exact int/ext Linux oracle pairs;baseline rejects all. Counted bytes including NUL,no path normalization,empty/root/trailing,70KiB,ownership/keyeffects andthrow.')
