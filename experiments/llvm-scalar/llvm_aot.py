#!/usr/bin/env python3
"""Experimental AOT driver using the installed rustc LLVM C API, no downloads."""
import ctypes as C, pathlib, sys, os
lib=os.environ.get('HARBOUR_LLVM_LIB')
if not lib: raise SystemExit('Set HARBOUR_LLVM_LIB to an LLVM23 shared library exposing the C API')
L=C.CDLL(lib)
p=C.c_void_p; i=C.c_int; z=C.c_size_t; c=C.c_char_p

def fn(n,r,*a):
 f=getattr(L,n);f.restype=r;f.argtypes=list(a);return f
ctx=fn('LLVMContextCreate',p)()
buf=p();err=c();mod=p();target=p()
if fn('LLVMCreateMemoryBufferWithContentsOfFile',i,c,C.POINTER(p),C.POINTER(c))(sys.argv[1].encode(),C.byref(buf),C.byref(err)):raise RuntimeError(err.value)
if fn('LLVMParseIRInContext',i,p,p,C.POINTER(p),C.POINTER(c))(ctx,buf,C.byref(mod),C.byref(err)):raise RuntimeError(err.value)
for n in ['LLVMInitializeX86TargetInfo','LLVMInitializeX86Target','LLVMInitializeX86TargetMC','LLVMInitializeX86AsmPrinter']:fn(n,None)()
triple=b'x86_64-pc-windows-gnu' if len(sys.argv)>3 and sys.argv[3]=='windows' else b'x86_64-unknown-linux-gnu'
if fn('LLVMGetTargetFromTriple',i,c,C.POINTER(p),C.POINTER(c))(triple,C.byref(target),C.byref(err)):raise RuntimeError(err.value)
tm=fn('LLVMCreateTargetMachine',p,p,c,c,c,i,i,i)(target,triple,b'x86-64',b'',3,1,3)
fn('LLVMSetTarget',None,p,c)(mod,triple)
dl=fn('LLVMCreateTargetDataLayout',p,p)(tm);ds=fn('LLVMCopyStringRepOfTargetData',c,p)(dl);fn('LLVMSetDataLayout',None,p,c)(mod,ds)
if fn('LLVMVerifyModule',i,p,i,C.POINTER(c))(mod,2,C.byref(err)):raise RuntimeError(err.value)
opts=fn('LLVMCreatePassBuilderOptions',p)()
e=fn('LLVMRunPasses',p,p,c,p,p)(mod,b'default<O3>',tm,opts)
if e:raise RuntimeError(fn('LLVMGetErrorMessage',c,p)(e))
if fn('LLVMVerifyModule',i,p,i,C.POINTER(c))(mod,2,C.byref(err)):raise RuntimeError(err.value)
fn('LLVMPrintModuleToFile',i,p,c,C.POINTER(c))(mod,(sys.argv[2]+'.opt.ll').encode(),C.byref(err))
if fn('LLVMTargetMachineEmitToFile',i,p,p,c,i,C.POINTER(c))(tm,mod,sys.argv[2].encode(),1,C.byref(err)):raise RuntimeError(err.value)
if fn('LLVMTargetMachineEmitToFile',i,p,p,c,i,C.POINTER(c))(tm,mod,(sys.argv[2]+'.s').encode(),0,C.byref(err)):raise RuntimeError(err.value)
