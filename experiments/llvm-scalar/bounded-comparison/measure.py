import subprocess,time,csv,pathlib,statistics,random
r=pathlib.Path(__file__).resolve().parent/'run';rows=[];modes=['pcode','gc3','default','llvm','rust']
for k in ['sum','bits','reverse']:
 expected=subprocess.check_output([str(r/(k+'-rust'))])
 for series in range(3):
  for rnd in range(9):
   order=modes[rnd%5:]+modes[:rnd%5]
   for m in order:
    t=time.perf_counter_ns();z=subprocess.run(['taskset','-c','0',str(r/(k+'-'+m))],capture_output=True,check=True);elapsed=time.perf_counter_ns()-t;assert z.stdout==expected
    if rnd>=2:rows.append([k,series,rnd,m,elapsed])
with open(r/'raw.csv','w')as f:csv.writer(f).writerows(rows)
for k in ['sum','bits','reverse']:
 print(k)
 for m in modes:
  med=[statistics.median(x[4]for x in rows if x[0]==k and x[1]==s and x[3]==m)/1e6 for s in range(3)];print(m,','.join(f'{x:.3f}'for x in med))
