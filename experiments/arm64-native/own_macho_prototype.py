"""Isolated own ARM64 Mach-O+ad-hoc-signature prototype, not hbc output.

No hardware execution has occurred. No externally copied implementation.
Facts are from Apple Mach-O/code-signing field layouts and ARM instruction
encodings independently checked against installed LLVM. Do not advertise
this file as a working Mac compiler or backend.
"""
import struct,hashlib
from pathlib import Path
r=Path(__file__).resolve().parent
u32=lambda *v:struct.pack('<'+'I'*len(v),*v)
u64=lambda *v:struct.pack('<'+'Q'*len(v),*v)
be=lambda *v:struct.pack('>'+'I'*len(v),*v)
align=lambda n,a:(n+a-1)&-a
base=0x100000000;entryoff=0x4000;message=b'ARM64 own writer probe\n'
# stp fp/lr; mov x0,1; adr x1,message; mov x2,len; mov x16,4;
# svc #0x80; mov x0,0; ldp fp/lr; ret. No x18. SP always 16-aligned.
words=[0xa9bf7bfd,0x910003fd,0xd2800020,0,0xd2800002|(len(message)<<5),
       0xd2800090,0xd4001001,0xd2800000,0xa8c17bfd,0xd65f03c0]
messageoff=entryoff+len(words)*4
relative=messageoff-(entryoff+3*4)
words[3]=0x10000001|((relative&3)<<29)|((relative>>2)<<5)
code=u32(*words)+message;textsize=align(entryoff+len(code),0x4000)
linkoff=textsize
# Empty rebase/bind/export opcodes; one null string. No absolute pointers or
# imported symbol stubs. libSystem loads for LC_MAIN startup/return handling.
linkdata=b'\0'*16;sigoff=align(linkoff+len(linkdata),16)
identifier=b'hbc-arm64-own-prototype\0';headerlen=88;hashoff=align(headerlen+len(identifier),8)
pages=(sigoff+4095)//4096;cdlength=hashoff+pages*32;sigsize=20+cdlength
fileend=sigoff+sigsize

def seg(name,va,ms,off,fs,prot,sections=()):
 result=u32(25,72+80*len(sections))+name.encode().ljust(16,b'\0')+u64(va,ms,off,fs)+u32(prot,prot,len(sections),0)
 for secname,addr,size,offset,flags in sections:
  result+=secname.encode().ljust(16,b'\0')+name.encode().ljust(16,b'\0')+u64(addr,size)+u32(offset,2,0,0,flags,0,0,0)
 return result

def strcmd(kind,path,extra=b''):
 payload=u32(12 if kind==14 else 24)+extra+path.encode()+b'\0';size=align(8+len(payload),8)
 return u32(kind,size)+payload+b'\0'*(size-8-len(payload))
commands=[seg('__PAGEZERO',0,base,0,0,0),
 seg('__TEXT',base,textsize,0,textsize,5,[('__text',base+entryoff,len(words)*4,entryoff,0x80000400),('__const',base+messageoff,len(message),messageoff,0)]),
 seg('__LINKEDIT',base+linkoff,align(fileend-linkoff,0x4000),linkoff,fileend-linkoff,1),
 u32(0x80000022,48,0,0,0,0,0,0,0,0,0,0), # empty dyld_info_only
 u32(2,24,linkoff,0,linkoff,1),
 u32(11,80,*([0]*18)),
 strcmd(14,'/usr/lib/dyld'),
 u32(27,24)+hashlib.sha256(code).digest()[:16],
 u32(50,24,1,0x000b0000,0x000b0000,0),
 u32(0x80000028,24)+u64(entryoff,0),
 strcmd(12,'/usr/lib/libSystem.B.dylib',u32(0,0x10000,0x10000)),
 u32(29,16,sigoff,sigsize)]
cmds=b''.join(commands)
header=u32(0xfeedfacf,0x0100000c,0,2,len(commands),len(cmds),0x200085,0)
assert len(header)+len(cmds)<=entryoff
body=bytearray(header+cmds);body.extend(b'\0'*(entryoff-len(body)));body.extend(code)
body.extend(b'\0'*(linkoff-len(body)));body.extend(linkdata);body.extend(b'\0'*(sigoff-len(body)))
cd=be(0xfade0c02,cdlength,0x20400,0x20002,hashoff,headerlen,0,pages,sigoff)
cd+=bytes([32,2,0,12])+be(0,0,0,0)+struct.pack('>Q',0)+struct.pack('>QQQ',0,textsize,1)
assert len(cd)==headerlen
cd+=identifier;cd+=b'\0'*(hashoff-len(cd))
for i in range(pages):cd+=hashlib.sha256(body[i*4096:min((i+1)*4096,sigoff)]).digest()
assert len(cd)==cdlength
body+=be(0xfade0cc0,sigsize,1,0,20)+cd
assert len(body)==fileend
(r/'own-arm64-macho').write_bytes(body)
(r/'own-arm64-instructions.bin').write_bytes(u32(*words))
print('Own prototype file generated, not executed:',len(body),'bytes,',pages,'signature pages')
