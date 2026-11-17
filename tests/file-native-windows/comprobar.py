"""FILE() en Windows real: compara hbc con Harbour clasico en un directorio aislado.
Uso: python comprobar.py --compiler hbc.exe --hbmk2 hbmk2.exe --clang clang.exe --out NUEVO_DIR
--hbmk2 y --clang son opcionales; sin hbmk2 se compara con file-exists.harbour.stdout.
"""
import argparse,hashlib,json,subprocess
from pathlib import Path
R=Path(__file__).resolve().parent
ap=argparse.ArgumentParser();ap.add_argument('--compiler',required=True);ap.add_argument('--hbmk2');ap.add_argument('--clang');ap.add_argument('--out',required=True);a=ap.parse_args()
out=Path(a.out).resolve();out.mkdir(parents=True,exist_ok=False);fs=out/'fs';(fs/'sub').mkdir(parents=True)
for name in ['Exact.TXT','noext','sub/nested.txt','oculto.txt','sistema.txt']:(fs/name).touch()
subprocess.run(['attrib','+h',str(fs/'oculto.txt')],check=True)
subprocess.run(['attrib','+s',str(fs/'sistema.txt')],check=True)
src=R/'file-exists.prg';expected=(R/'file-exists.harbour.stdout').read_bytes();rows=[]
def run(cmd,cwd=out):
    p=subprocess.run(list(map(str,cmd)),cwd=cwd,capture_output=True,timeout=90)
    assert p.returncode==0,(cmd,p.stdout,p.stderr);return p
if a.hbmk2:
    run([a.hbmk2,src,'-gtstd','-q','-o'+str(out/'oracle'),'-workdir='+str(out/'work')])
    p=run([out/'oracle.exe'],fs);assert p.stdout==expected and not p.stderr,'Harbour difiere del esperado guardado'
    rows.append(dict(id='harbour',stdout_sha256=hashlib.sha256(p.stdout).hexdigest()))
run([a.compiler,src,out/'pe.exe','--target=windows','--instrument'])
p=run([out/'pe.exe'],fs);assert p.stdout==expected and not p.stderr,'PE difiere de Harbour'
rows.append(dict(id='pe',stdout_sha256=hashlib.sha256(p.stdout).hexdigest()))
if a.clang:
    run([a.compiler,src,out/'coff.s','--target=windows','--instrument'])
    run([a.clang,'-c',out/'coff.s','-o',out/'coff.obj'])
    run([a.clang,'-nostdlib','-Wl,-e,_start',out/'coff.obj','-lkernel32','-o',out/'coff.exe'])
    p=run([out/'coff.exe'],fs);assert p.stdout==expected and not p.stderr,'COFF difiere de Harbour'
    rows.append(dict(id='coff',stdout_sha256=hashlib.sha256(p.stdout).hexdigest()))
report=dict(compiler_sha256=hashlib.sha256(Path(a.compiler).read_bytes()).hexdigest(),source_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),results=rows)
(out/'verificacion.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print('PASS',len(rows),'ejecuciones identicas byte a byte')
