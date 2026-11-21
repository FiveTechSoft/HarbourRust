from common import *
a=setup(True);rows=[]
for name,source in json.loads(Path(__file__).with_name('cases.json').read_text()).items():
 w=a.output/name;w.mkdir();rows.append(dict(name=name,**exact(a,w,source)));print(name,'EXACT int/ext',flush=True)
finish(a,rows,'18own sources36exact int/ext Linux oracle pairs;baseline rejects all. Date grid11550inputs,year0,centuries,leap,short,long,NUL,temporary,parameter,effect once,throw. One typed string alias to own measured SToD path.')
