"""Copy only engine source into the authorized delivery directory and package."""
import argparse,shutil,zipfile,json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument("output");args=p.parse_args()
output=Path(args.output).resolve();output.mkdir(parents=True,exist_ok=True)
source=output/"source"
shutil.copytree(root,source,dirs_exist_ok=True,ignore=shutil.ignore_patterns("__pycache__","*.pyc",".git"))
addon=output/"addon"/"quadruped_blender"
shutil.copytree(root/"quadruped_blender",addon,dirs_exist_ok=True,ignore=shutil.ignore_patterns("__pycache__"))
shutil.copytree(root/"quadruped_core",addon/"quadruped_core",dirs_exist_ok=True,ignore=shutil.ignore_patterns("__pycache__"))
for name in ("profiles","presets"):shutil.copytree(root/name,addon/"data"/name,dirs_exist_ok=True)
init=addon/"__init__.py"
init.write_text("import sys\nfrom pathlib import Path\nsys.path.insert(0,str(Path(__file__).parent))\n"+init.read_text())
archive=output/"QuadrupedStudio.zip"
with zipfile.ZipFile(archive,"w",zipfile.ZIP_DEFLATED) as z:
    for file in addon.rglob("*"):
        if file.is_file():z.write(file,file.relative_to(addon.parent))
for name in ("profiles","animations","poses","runtime","working","exports","qa"):(output/name).mkdir(exist_ok=True)
shutil.copy2(root/"profiles/frostfang_v3.json",output/"profiles/frostfang_v3.json")
for file in (root/"presets/animations").glob("*.json"):shutil.copy2(file,output/"animations"/file.name)
shutil.copytree(root/"runtime",output/"runtime",dirs_exist_ok=True)
print("PACKAGED",archive)
