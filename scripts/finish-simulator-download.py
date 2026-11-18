from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import subprocess, shutil
root=Path(__file__).resolve().parents[1]
url=(root/'downloads/simulator-url.txt').read_text().strip()
total=468689762
chunk=(total+7)//8
parts=root/'downloads/simulator-parts'
def finish(i):
 p=parts/str(i); start=i*chunk; end=min(total,(i+1)*chunk)-1
 n=p.stat().st_size if p.exists() else 0
 if n==end-start+1:return
 tail=p.with_suffix('.tail')
 subprocess.run(['curl','-fsSL','--max-time','600','--retry','3','--range',f'{start+n}-{end}',url,'-o',str(tail)],check=True)
 assert tail.stat().st_size==end-start+1-n,(i,tail.stat().st_size)
 with p.open('ab') as out,tail.open('rb') as inp:shutil.copyfileobj(inp,out)
 tail.unlink()
 print('Part complete',i,flush=True)
with ThreadPoolExecutor(max_workers=4) as pool:list(pool.map(finish,range(8)))
with (root/'downloads/meta_xr_simulator_v207.1.dmg').open('wb') as out:
 for i in range(8):
  with (parts/str(i)).open('rb') as inp:shutil.copyfileobj(inp,out)
print('SIMULATOR_DOWNLOAD_COMPLETE',flush=True)
