"""Integration tests for installed UI operators, persistence and export."""
import bpy,sys,json,traceback
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT))
out=Path(sys.argv[sys.argv.index("--")+1]);out.mkdir(parents=True,exist_ok=True)
try:
    import quadruped_blender
    quadruped_blender.register()
    from quadruped_blender.ui import current_definition
    source=Path.home()/"Documents/Roblox/DungeonMMO_CanineRig_QA/Frostfang_20260923/RigFunctionQA_20260923/TailRepairV3_Tip/Frostfang_TailSkinV3_Tip_UNAPPROVED.blend"
    bpy.ops.wm.open_mainfile(filepath=str(source))
    rig=bpy.data.objects["Frostfang_Canine_CompactRig"]
    bpy.context.view_layer.objects.active=rig;rig.select_set(True)
    s=bpy.context.scene.qae;s.output_dir=str(out);s.name="Operator_Custom";s.duration=.5;s.fps=12
    s.head_yaw=.12;s.tail_yaw=.06
    assert bpy.ops.quadruped.generate()=={"FINISHED"}
    before=rig.animation_data.action
    assert bpy.ops.quadruped.save_animation()=={"FINISHED"}
    assert (out/"animations/Operator_Custom.json").exists()
    s.stride=.2
    assert bpy.ops.quadruped.load_animation(filepath=str(out/"animations/Operator_Custom.json"))=={"FINISHED"}
    assert abs(s.stride-.44)<1e-6
    assert bpy.ops.quadruped.reset_neutral()=={"FINISHED"}
    rig.pose.bones["DEF_spine.011"].rotation_mode="QUATERNION"
    from mathutils import Quaternion
    rig.pose.bones["DEF_spine.011"].rotation_quaternion=Quaternion((0,0,1),.12)
    assert bpy.ops.quadruped.save_pose()=={"FINISHED"}
    assert bpy.ops.quadruped.reset_neutral()=={"FINISHED"}
    assert bpy.ops.quadruped.load_pose(filepath=str(out/"poses/Operator_Custom.json"))=={"FINISHED"}
    assert s.use_pose
    assert bpy.ops.quadruped.generate()=={"FINISHED"}
    assert bpy.ops.quadruped.bake_export()=={"FINISHED"}
    manifests=list((out/"exports").glob("*/manifest.json"))
    assert manifests,"export manifest missing"
    manifest=json.loads(manifests[-1].read_text())
    assert len(manifest["bones"])==33
    assert any(b["name"]=="DEF_spine" for b in manifest["bones"])
    print("QAE_UI_OPERATORS_PASS",manifests[-1],flush=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(out/"Frostfang_Authoring.blend"))
except Exception:
    traceback.print_exc();sys.exit(1)
