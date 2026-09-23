"""Actual controlled-rig validation and repeatability, no file overwrite."""
import sys,json,copy
from pathlib import Path
import bpy
ENGINE=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ENGINE))
from quadruped_blender.refine_walk import generate
ROOT=Path.home()/"Documents/Roblox/DungeonMMO_CanineRig_QA/Frostfang_20260923/GroundedWalkTrial_20260923"
bpy.ops.wm.open_mainfile(filepath=str(ROOT/"WalkV16_PawPadGait/Frostfang_WalkV16_UNAPPROVED.blend"))
rig=bpy.data.objects["Frostfang_Canine_CompactRig"];scene=bpy.context.scene
config=json.loads((ENGINE/"profiles/frostfang_v16_refinement.json").read_text())
original=rig.animation_data.action;target=bpy.data.objects[config["limbs"][0]["target"]];target_action=target.animation_data.action
for key,value in (("settle",0),("pelvis","missing")):
    bad=copy.deepcopy(config);bad[key]=value
    try:generate(rig,bad);raise AssertionError("invalid config accepted")
    except ValueError:pass
    assert rig.animation_data.action==original and target.animation_data.action==target_action
a=generate(rig,config)
def samples():
    result={}
    for frame in (1,49,88,103,145,scene.frame_end):
        scene.frame_set(frame);bpy.context.view_layer.update()
        result[frame]={b.name:[list(row) for row in b.matrix] for b in rig.pose.bones}
    return result
first=samples();b=generate(rig,config);second=samples()
error=max(abs(x-y) for f in first for n in first[f] for r,s in zip(first[f][n],second[f][n]) for x,y in zip(r,s))
assert error<1e-5,error
assert a==b
assert a[0]["cycles"]==0 and a[-1]["cycles"]==4
report={"invalid_settings_preserve_actions":True,"repeat_generation_matrix_error":error,"sampled_frames":list(first),"records_identical":a==b,"frames":len(a)}
(ROOT/"ForelegRefinement_20260923_E"/"regeneration_test.json").write_text(json.dumps(report,indent=2))
print("REFINEMENT_REGENERATION_PASS",json.dumps(report),flush=True)
