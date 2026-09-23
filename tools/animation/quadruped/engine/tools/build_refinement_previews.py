"""Assemble actual Blender renders, preserving the complete timeline."""
from pathlib import Path
from PIL import Image,ImageDraw
import json
ROOT=Path.home()/"Documents/Roblox/DungeonMMO_CanineRig_QA/Frostfang_20260923/GroundedWalkTrial_20260923/ForelegRefinement_20260923_E"
records=json.loads((ROOT/"audit.json").read_text())["frames"]
frames=list(range(1,len(records)+1,2))
def tile(view,f):
    with Image.open(ROOT/"preview"/view/f"{f:04d}.png") as im:result=im.convert("RGB")
    draw=ImageDraw.Draw(result)
    t=(f-1)/24
    label="IDLE" if t<2 else "WEIGHT SHIFT" if t<2.25 else "WALK" if records[f-1]["cycles"]<4 else "SETTLE / IDLE"
    draw.rectangle((0,0,700,24),fill=(22,27,35))
    draw.text((12,7),f"FROSTFANG | {view.replace('_',' ').upper()} | {label} | {t:.2f}s",fill="white")
    return result
def save(name,views):
    result=[]
    for f in frames:
        tiles=[tile(v,f) for v in views]
        if len(tiles)==1:im=tiles[0]
        else:
            im=Image.new("RGB",(1400,960))
            for i,t in enumerate(tiles):im.paste(t,((i%2)*700,(i//2)*480))
        result.append(im.quantize(colors=128))
    durations=[80 if i%3!=2 else 90 for i in range(len(result))]
    path=ROOT/(name+".gif")
    result[0].save(path,save_all=True,append_images=result[1:],duration=durations,loop=0,disposal=2,optimize=False)
    with Image.open(path) as im:
        duration=0
        for i in range(im.n_frames):im.seek(i);duration+=im.info["duration"]
        assert abs(duration/1000-len(frames)/12)<.05
        print(path,im.n_frames,duration,path.stat().st_size,flush=True)
save("Frostfang_FullBody_Side",["side"])
save("Frostfang_Foreleg_Closeup",["foreleg_close"])
save("Frostfang_FourViews",["side","three_quarter","front","rear"])
