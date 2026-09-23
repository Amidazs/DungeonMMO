"""Run via Blender --background --python this.py -- --output PATH."""
import sys,json,hashlib,argparse,traceback
from pathlib import Path
import bpy
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT))
parser=argparse.ArgumentParser();parser.add_argument("--output",required=True)
args=parser.parse_args(sys.argv[sys.argv.index("--")+1:])
out=Path(args.output);out.mkdir(parents=True,exist_ok=True)
source=Path.home()/"Documents/Roblox/DungeonMMO_CanineRig_QA/Frostfang_20260923/RigFunctionQA_20260923/TailRepairV3_Tip/Frostfang_TailSkinV3_Tip_UNAPPROVED.blend"
report={"checks":[],"source":str(source),"status":"RUNNING"}
def check(label,condition):
    report["checks"].append({"name":label,"pass":bool(condition)})
    if not condition:raise AssertionError(label)
try:
    from quadruped_core.storage import load
    from quadruped_blender.adapter import calibrate
    from quadruped_blender.authoring import generate,reset_neutral
    from quadruped_blender.bake import bake
    original=hashlib.sha256(source.read_bytes()).hexdigest()
    bpy.ops.wm.open_mainfile(filepath=str(source))
    rig=bpy.data.objects["Frostfang_Canine_CompactRig"]
    profile=load(ROOT/"profiles/frostfang_v3.json","profile")
    cal=calibrate(rig,profile)
    check("33 actual bones",len(cal["bones"])==33)
    check("tail includes terminal",profile["groups"]["tail"][-1] in cal["bones"])
    check("hind asymmetry measured",abs(cal["limbs"]["HindLeft"]["length"]-cal["limbs"]["HindRight"]["length"])>1e-4)
    bad=json.loads(json.dumps(profile));bad["roles"]["Head"]="absent"
    try:calibrate(rig,bad);raise AssertionError("missing mapping accepted")
    except ValueError:check("missing bone rejected",True)
    generated={}
    for name in ("idle","walk","look","tail"):
        definition=load(ROOT/f"presets/animations/{name}.json","animation")
        action=generate(rig,profile,definition,{})
        generated[name]=action.name
        bpy.context.scene.frame_set(1)
        before=rig.pose.bones[profile["groups"]["tail"][-1]].matrix.copy()
        bpy.context.scene.frame_set(16)
        after=rig.pose.bones[profile["groups"]["tail"][-1]].matrix.copy()
        check(name+" terminal moves",sum(abs(before[i][j]-after[i][j]) for i in range(4) for j in range(4))>1e-5)
        baked=bake(rig,action,1,61)
        check(name+" independent bake",baked!=action)
        reset_neutral(rig)
        check(name+" neutral reset",all(sum(abs(b.matrix_basis[i][j]-(1 if i==j else 0)) for i in range(4) for j in range(4))<1e-5 for b in rig.pose.bones))
    check("source hash unchanged",hashlib.sha256(source.read_bytes()).hexdigest()==original)
    report.update(status="PASS",source_sha256=original,actions=generated,calibration=cal)
    bpy.ops.wm.save_as_mainfile(filepath=str(out/"Frostfang_Engine_QA.blend"))
except Exception:
    report.update(status="FAIL",error=traceback.format_exc());print(report["error"])
finally:
    (out/"blender_integration.json").write_text(json.dumps(report,indent=2))
    print("QUADRUPED_RESULT",report["status"],len(report["checks"]),flush=True)
if report["status"]!="PASS":sys.exit(1)
