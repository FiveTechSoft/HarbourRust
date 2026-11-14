"""Independent reference generator, research-only. Not part of hbc's build.
Uses installed LLVM C API to make an AArch64 Mach-O object from plain LLVM IR.
"""
import ctypes as c
import sys
from pathlib import Path
root=Path(__file__).resolve().parent
import os
ll=c.CDLL(os.environ['LLVM_SHARED_LIBRARY']) # independent development oracle only
def api(name,restype,args):
 f=getattr(ll,name);f.restype=restype;f.argtypes=args;return f
P=c.c_void_p;S=c.c_char_p;I=c.c_int;Z=c.c_size_t
for s in ['TargetInfo','Target','TargetMC','AsmPrinter','AsmParser']:
 api('LLVMInitializeAArch64'+s,None,[])()
ctx=api('LLVMContextCreate',P,[])()
input_path=Path(sys.argv[1]) if len(sys.argv)>1 else root/'reference-main.ll'
stem=sys.argv[2] if len(sys.argv)>2 else 'reference-main'
text=input_path.read_bytes()
buf=api('LLVMCreateMemoryBufferWithMemoryRangeCopy',P,[S,Z,S])(text,len(text),b'reference')
module=P();err=S()
assert api('LLVMParseIRInContext',I,[P,P,c.POINTER(P),c.POINTER(S)])(ctx,buf,c.byref(module),c.byref(err))==0,err.value
triple=b'arm64-apple-macosx11.0.0';target=P()
assert api('LLVMGetTargetFromTriple',I,[S,c.POINTER(P),c.POINTER(S)])(triple,c.byref(target),c.byref(err))==0,err.value
machine=api('LLVMCreateTargetMachine',P,[P,S,S,S,I,I,I])(target,triple,b'apple-m1',b'',2,2,0)
api('LLVMSetTarget',None,[P,S])(module,triple)
for kind,name in [(0,stem+'.s'),(1,stem+'.o')]:
 assert api('LLVMTargetMachineEmitToFile',I,[P,P,S,I,c.POINTER(S)])(machine,module,str(root/name).encode(),kind,c.byref(err))==0,err.value
api('LLVMDisposeTargetMachine',None,[P])(machine)
api('LLVMDisposeModule',None,[P])(module)
api('LLVMContextDispose',None,[P])(ctx)
print('Independent reference generated:',stem+'.s',stem+'.o')
