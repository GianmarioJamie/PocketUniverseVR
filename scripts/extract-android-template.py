#!/usr/bin/env python3
"""Read official Godot template ZIP index over HTTP ranges, download Android source only."""
import io, json, pathlib, subprocess, zipfile, shutil
root = pathlib.Path(__file__).resolve().parents[1]
meta = json.loads((root / 'downloads/godot-release.json').read_text())
a = next(x for x in meta['assets'] if x['name'].endswith('_export_templates.tpz') and '_mono_' not in x['name'])
class RemoteZip(io.RawIOBase):
 def __init__(self,url,size): self.url=url; self.size=size; self.pos=0
 def seekable(self): return True
 def readable(self): return True
 def tell(self): return self.pos
 def seek(self,off,whence=0):
  self.pos = off if whence==0 else self.pos+off if whence==1 else self.size+off
  return self.pos
 def read(self,n=-1):
  if n<0:n=self.size-self.pos
  if n==0:return b''
  end=min(self.size-1,self.pos+n-1)
  data=subprocess.check_output(['curl','-fsSL','--retry','3','--max-time','120','--range',f'{self.pos}-{end}',self.url])
  if len(data)>n:raise RuntimeError('Server ignored range')
  self.pos+=len(data)
  return data
r=RemoteZip(a['browser_download_url'],a['size'])
with zipfile.ZipFile(r) as z:
 names=[i for i in z.infolist() if i.filename.endswith(('android_source.zip','version.txt'))]
 for i in names:
  print(i.filename,i.file_size,i.compress_size,flush=True)
  dest=root/'downloads'/('android_source.zip' if i.filename.endswith('android_source.zip') else 'android-template-version.txt')
  with z.open(i) as source, dest.open('wb') as out:shutil.copyfileobj(source,out,1024*1024)
  print('Downloaded',dest.name,flush=True)
