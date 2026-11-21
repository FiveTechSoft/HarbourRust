"""Own MIT fixtures and fail-closed execution helpers for typed Obj return ownership."""
from pathlib import Path
import os,signal,subprocess,hashlib
ENV=dict(os.environ,PATH='/tmp/toolchain/bin:'+os.environ['PATH'],WINEDEBUG='-all')
MODES=[('int',[]),('ext',['--external-as']),('no-vas',['--no-vas-arrays']),('ext-no-vas',['--external-as','--no-vas-arrays']),('no-escape',['--no-escape-analysis'])]
CLASSES='''#include "hbclass.ch"
class Uno
 data value init 17
 data text init "retained"
 method Same()
 method SameRelay()
endclass
method Same() class Uno
return Self
method SameRelay() class Uno
return Self:Same()
class Dos
 method Fresh()
 method Relay()
endclass
method Fresh() class Dos
return Uno():New()
method Relay() class Dos
return Make()
class Child from Dos
 method Fresh()
endclass
method Fresh() class Child
return Make()
'''
DEFS='''function Make()
return Uno():New()
function Relay()
return Make()
function Relay2()
return Relay()
function LocalObj()
local a:=Uno():New()
return a
function Param(o)
o:Same()
return o
function Choice(flag)
local a:=Uno():New()
if flag
return Make()
endif
return a
function Byref(n)
n++
return Make()
'''
# expr, byref increments per iteration, aliases caller owner
CASES={
'factory':('Make()',0,False),
'call-relay':('Relay2()',0,False),
'method-fresh':('b:Fresh()',0,False),
'method-relay':('b:Relay()',0,False),
'inherited-virtual':('child:Fresh()',0,False),
'fresh-receiver':('Uno():New():SameRelay()',0,False),
'borrow-local':('LocalObj()',0,False),
'borrow-parameter':('Param(a)',0,True),
'borrow-self':('a:Same()',0,True),
'self-relay':('a:SameRelay()',0,True),
'choice-fresh':('Choice(.T.)',0,False),
'choice-borrowed':('Choice(.F.)',0,False),
'byref-factory':('Byref(@k)',1,False),
}
def source(name,count=7,memory=False):
 expr,inc,alias=CASES[name]
 work='''function Work(n)
local a:=Uno():New(),b:=Dos():New(),child:=Child():New(),c:=Uno():New(),trash:=Uno():New(),i,k:=0
for i:=1 to n
c:='''+expr+'''
trash:=Uno():New()
trash:value:=99
trash:text:="clobbered"
if c:value!=17 .or. a:value!=17 .or. c:text!="retained" .or. a:text!="retained"
? "BAD-VALUE"
endif
if '''+('!(c==a)' if alias else 'c==a')+'''
? "BAD-IDENTITY"
endif
next
return n+k
'''
 main=('''function Main()
local before,n
Work(3)
before:=hb_memcheck()
n:=Work('''+str(count)+''')
? n,hb_memcheck()-before
return nil
''' if memory else '''function Main()
? Work('''+str(count)+''')
return nil
''')
 return CLASSES+DEFS+work+main

def h(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def run(cmd,w,label,timeout=20):
 p=subprocess.Popen(list(map(str,cmd)),cwd=w,env=ENV,stdout=subprocess.PIPE,stderr=subprocess.PIPE,start_new_session=True)
 try:so,se=p.communicate(timeout=timeout);timed=False
 except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL);so,se=p.communicate();timed=True
 for ext,b in [('stdout',so),('stderr',se),('rc',str(p.returncode).encode())]:(w/(label+'.'+ext)).write_bytes(b)
 return p.returncode,so,se,timed
