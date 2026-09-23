"""Install the packaged UI and save a separate ready-to-use authoring scene."""
import bpy,sys,json
from pathlib import Path
output=Path(sys.argv[sys.argv.index("--")+1])
bpy.ops.preferences.addon_install(filepath=str(output/"QuadrupedStudio.zip"),overwrite=True)
bpy.ops.preferences.addon_enable(module="quadruped_blender")
bpy.ops.wm.save_userpref()
bpy.ops.wm.open_mainfile(filepath=str(output/"qa/blender_20260923_a/Frostfang_Engine_QA.blend"))
rig=bpy.data.objects["Frostfang_Canine_CompactRig"]
for o in bpy.context.selected_objects:o.select_set(False)
rig.select_set(True);bpy.context.view_layer.objects.active=rig
rig.animation_data.action=bpy.data.actions["QAE_walk"];bpy.context.scene.frame_set(1)
s=bpy.context.scene.qae;s.output_dir=str(output);s.name="Frostfang_Walk";s.animation="Walk"
s.bone="DEF_spine.011"
for area in bpy.context.screen.areas:
    if area.type=="VIEW_3D":
        area.spaces.active.show_region_ui=True
        area.spaces.active.shading.type="MATERIAL"
        area.spaces.active.region_3d.view_distance=2.3
        area.spaces.active.region_3d.view_location=(0,0,.5)
        from mathutils import Quaternion
        area.spaces.active.region_3d.view_rotation=Quaternion((.7071,.0,.7071,.0))
bpy.context.scene.frame_end=60
bpy.ops.wm.save_as_mainfile(filepath=str(output/"working/Frostfang_QuadrupedStudio.blend"))
print("QAE_INSTALLED",output)
