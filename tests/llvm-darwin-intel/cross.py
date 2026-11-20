import ctypes as C,sys,pathlib,os
L=C.CDLL(os.environ['HARBOUR_LLVM_LIB']);p=C.c_void_p;c=C.c_char_p;i=C.c_int;z=C.c_size_t
def fn(n,r,*a):f=getattr(L,n);f.restype=r;f.argtypes=list(a);return f
triple=sys.argv[3].encode() if len(sys.argv)>3 else b'x86_64-apple-macos14'
arch='AArch64' if triple.startswith(b'arm64') else 'X86'
for n in ['TargetInfo','Target','TargetMC','AsmPrinter','AsmParser']:fn('LLVMInitialize'+arch+n,None)()
ctx=fn('LLVMContextCreate',p)();err=c();mod=p();tgt=p();b=pathlib.Path(sys.argv[1]).read_bytes()
if sys.argv[1].endswith('.ll'):
 buf=fn('LLVMCreateMemoryBufferWithMemoryRangeCopy',p,c,z,c)(b,len(b),b'in')
 if fn('LLVMParseIRInContext',i,p,p,C.POINTER(p),C.POINTER(c))(ctx,buf,C.byref(mod),C.byref(err)):raise RuntimeError(err.value)
else:
 mod=fn('LLVMModuleCreateWithNameInContext',p,c,p)(b'asm',ctx);fn('LLVMSetModuleInlineAsm2',None,p,c,z)(mod,b,len(b))
assert not fn('LLVMGetTargetFromTriple',i,c,C.POINTER(p),C.POINTER(c))(triple,C.byref(tgt),C.byref(err)),err.value
tm=fn('LLVMCreateTargetMachine',p,p,c,c,c,i,i,i)(tgt,triple,b'generic',b'',2,2,3);fn('LLVMSetTarget',None,p,c)(mod,triple)
dl=fn('LLVMCreateTargetDataLayout',p,p)(tm);ds=fn('LLVMCopyStringRepOfTargetData',c,p)(dl);fn('LLVMSetDataLayout',None,p,c)(mod,ds)
if fn('LLVMVerifyModule',i,p,i,C.POINTER(c))(mod,2,C.byref(err)):raise RuntimeError(err.value)
if fn('LLVMTargetMachineEmitToFile',i,p,p,c,i,C.POINTER(c))(tm,mod,sys.argv[2].encode(),1,C.byref(err)):raise RuntimeError(err.value)
