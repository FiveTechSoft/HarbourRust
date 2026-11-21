from common import *
a=setup(True);rows=[]
cases={
'flat-before':'function Main()\nlocal a:={1,2,3}\n? Pick(a)\nreturn nil\nfunction Pick(p)\nlocal n:=Len(p)\nreturn n+p[1]\n',
'flat-after':'function Main()\nlocal a:={1,2,3}\n? Pick(a)\nreturn nil\nfunction Pick(p)\nlocal n:=p[1]\nreturn n+Len(p)\n',
'array-string':'function Main()\nlocal a:={"ab","cd"}\n? Pick(a)\nreturn nil\nfunction Pick(p)\nlocal n:=Len(p)\nAAdd(p,"ef")\nreturn n+Len(p)\n',
'add-before':'function Main()\nlocal a:=Array(2)\n? Pick(a)\nreturn nil\nfunction Pick(p)\nlocal n:=Len(p)\nAAdd(p,7)\nreturn n+Len(p)\n',
'add-after':'function Main()\nlocal a:=Array(2)\n? Pick(a)\nreturn nil\nfunction Pick(p)\nAAdd(p,7)\nreturn Len(p)\n',
'hash':'function Main()\nlocal h:={"x"=>7}\n? Pick(h)\nreturn nil\nfunction Pick(p)\nlocal n:=Len(p)\nreturn n+p["x"]\n',
'print-array':'function Main()\nlocal a:=Array(3)\n? Pick(a)\nreturn nil\nfunction Pick(p)\nreturn Len(p)\n',
'string-local':'function Main()\nlocal p:="ab"\n? Len(p),Upper(p)\nreturn nil\n',
}
for name,source in cases.items():
 w=a.output/name;w.mkdir();row=exact(a,w,source,False);assert row['results']['base']['build_rc']==0,(name,row);rows.append(dict(name=name,**row));print(name,'EXACT int/ext',flush=True)
finish(a,rows,'8prior controls,int/ext exact oracle;baseline accepts all. Deferred Len keeps array/hash evidence,typed local strings unchanged.')
