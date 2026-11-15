from pathlib import Path
import subprocess,struct,hashlib,json,os
R=Path(__file__).resolve().parents[2];O=R/'evidence'/'header-gate';O.mkdir(parents=True,exist_ok=True);rows=[]
for source in ['tests/macro-m1/contexts.prg','tests/macro-m1/literals.prg','tests/macro/m1-values.prg','tests/t828_macro_named_rejection_neg.prg']:
 d=O/Path(source).stem;d.mkdir(exist_ok=True);raw=[]
 for label,cc in [('base',os.environ.get('HB_BASE_COMPILER','/tmp/hr-b2-hbc-final')),('candidate',os.environ.get('HB_FIX_COMPILER','/tmp/hr-b2-pe-noaslr'))]:
  exe=d/(label+'.exe');q=subprocess.run([cc,source,str(exe),'--target=windows','-I','tests'],capture_output=True,cwd=R);assert not q.returncode,q.stderr
  b=bytearray(exe.read_bytes());p=struct.unpack_from('<I',b,0x3c)[0];o=p+24;flags=struct.unpack_from('<H',b,o+70)[0];rel=struct.unpack_from('<II',b,o+112+8*5)
  assert flags==(0x160 if label=='base' else 0x100),(label,hex(flags));assert rel==(0,0)
  # Header timestamp and checksum vary naturally. No code/data bytes masked.
  sha=hashlib.sha256(b).hexdigest();b[p+8:p+12]=b'\0'*4;b[o+64:o+68]=b'\0'*4;raw.append(bytes(b));rows.append(dict(source=source,label=label,sha256=sha,dll_characteristics=hex(flags),reloc_directory=rel));exe.unlink()
 diffs=[i for i,(a,b)in enumerate(zip(*raw))if a!=b];assert len(raw[0])==len(raw[1]);assert diffs==[0xde],diffs
(O/'results.json').write_text(json.dumps(rows,indent=2)+'\n');print('four PE complete-image byte comparisons: only DllCharacteristics0x60 bits differ after timestamp/checksum masking; NX intact, relocation directory empty')
