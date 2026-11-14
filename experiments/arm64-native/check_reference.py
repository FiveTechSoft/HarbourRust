"""Independent verifier for the isolated own ARM64 Mach-O writer profile.
Checks layout and CodeDirectory hashes, not Apple loader/security acceptance.
Uses only the Python standard library and contains no production writer code.
"""
from pathlib import Path
import struct, hashlib, json, sys
p=Path(sys.argv[1]); b=p.read_bytes()
def u(fmt,off):
    assert 0<=off and off+struct.calcsize(fmt)<=len(b),'truncated field'
    return struct.unpack_from(fmt,b,off)
def text(raw):return raw.split(b'\0',1)[0].decode('ascii')
magic,cpu,sub,kind,ncmd,cmdsz,flags,reserved=u('<8I',0)
assert (magic,cpu,sub,kind,reserved)==(0xfeedfacf,0x0100000c,0,2,0)
assert flags==0x200085 and 32+cmdsz<=0x4000
segments=[];sections=[];commands=[];sig=None;entry=None;o=32;unique=set()
for _ in range(ncmd):
    cmd,sz=u('<II',o);assert sz>=8 and sz%8==0 and o+sz<=32+cmdsz
    row={'cmd':cmd,'size':sz};assert cmd==25 or cmd not in unique
    unique.add(cmd)
    if cmd==25:
        raw,va,ms,off,fs,mx,prot,ns,sgfl=u('<16sQQQQIIII',o+8);name=text(raw)
        assert sz==72+ns*80 and off+fs<=len(b) and ms>=fs and sgfl==0
        assert va%16384==0 and off%16384==0 and ms%16384==0
        assert mx==prot and not(prot&2 and prot&4)
        row.update(name=name,vmaddr=va,memory_size=ms,fileoff=off,filesize=fs,maximum=mx,initial=prot)
        segments.append(row)
        for j in range(ns):
            q=o+72+j*80
            sec,seg,addr,size,soff,align,reloff,nreloc,sflags,r1,r2,r3=u('<16s16sQQ8I',q)
            assert text(seg)==name and align==2 and reloff==nreloc==r1==r2==r3==0
            assert off<=soff and soff+size<=off+fs and addr==va+(soff-off)
            sections.append({'name':text(sec),'address':addr,'size':size,'offset':soff,'flags':sflags})
    elif cmd in [12,14]:
        no=u('<I',o+8)[0];assert 12<=no<sz
        raw=b[o+no:o+sz];assert b'\0'in raw
        row['path']=text(raw)
    elif cmd==0x80000028:
        assert sz==24;entry,stack=u('<QQ',o+8);assert stack==0;row['entryoff']=entry
    elif cmd==29:
        assert sz==16;sig=u('<II',o+8);row.update(signature_offset=sig[0],signature_size=sig[1])
    elif cmd==0x80000022:
        assert sz==48 and u('<10I',o+8)==(0,)*10
    elif cmd==50:
        assert sz==24 and u('<4I',o+8)==(1,0xb0000,0xb0000,0)
    elif cmd==27:assert sz==24
    elif cmd in [2,11]:pass
    else:raise AssertionError(('unknown load command',cmd))
    commands.append(row);o+=sz
assert o==32+cmdsz and len(commands)==12
assert [s['name']for s in segments]==['__PAGEZERO','__TEXT','__LINKEDIT']
z,t,l=segments
assert (z['vmaddr'],z['memory_size'],z['fileoff'],z['filesize'],z['initial'])==(0,0x100000000,0,0,0)
assert t['vmaddr']==0x100000000 and t['fileoff']==0 and t['initial']==5
assert l['vmaddr']==t['vmaddr']+t['memory_size'] and l['fileoff']==t['filesize'] and l['initial']==1
assert l['fileoff']+l['filesize']==len(b)
assert [s['name']for s in sections]==['__text','__const']
c,d=sections
assert c['offset']==0x4000 and c['size']>0 and c['size']%4==0 and c['flags']==0x80000400
assert d['offset']==c['offset']+c['size'] and d['flags']==0
assert c['offset']<=entry<c['offset']+c['size'] and entry%4==0
assert [x['path']for x in commands if 'path'in x]==['/usr/lib/dyld','/usr/lib/libSystem.B.dylib']
assert sig is not None
s,n=sig;assert s%16==0 and s+n==len(b) and s>=l['fileoff']
magic,length,count=u('>III',s);assert (magic,length,count)==(0xfade0cc0,n,1)
typ,off=u('>II',s+12);assert (typ,off)==(0,20)
q=s+off
magic,length,version,cdflags,hashoff,identoff,nspecial,ncode,limit=u('>9I',q)
assert magic==0xfade0c02 and version==0x20400 and cdflags==0x20002 and q+length==len(b)
assert nspecial==0 and identoff==88 and 88<hashoff<length
assert b'\0'in b[q+identoff:q+hashoff]
hsize,htype,platform,pagelog=u('>4B',q+36)
assert (hsize,htype,platform,pagelog)==(32,2,0,12)
assert u('>4I',q+40)==(0,0,0,0) and u('>Q',q+56)==(0,)
execbase,execlimit,execflags=u('>QQQ',q+64)
assert (execbase,execlimit,execflags)==(0,t['filesize'],1)
assert limit==s and ncode==(limit+4095)//4096 and hashoff+ncode*32==length
for k in range(ncode):
    page=b[k*4096:min((k+1)*4096,limit)]
    assert hashlib.sha256(page).digest()==b[q+hashoff+k*32:q+hashoff+(k+1)*32],('signature hash',k)
out={'file_sha256':hashlib.sha256(b).hexdigest(),'cpu':'arm64','pie':True,'dynamic':True,'commands':commands,'sections':sections,'signature':{'version':version,'flags':cdflags,'adhoc':True,'hash':'SHA256','code_pages':ncode,'page_bytes':4096,'code_limit':limit,'all_page_hashes_match':True},'scope':'own writer profile layout and mathematical hashes only; not macOS loading/execution/security validation'}
(p.parent/(p.name+'-structure.json')).write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps(out['signature'],indent=2))
