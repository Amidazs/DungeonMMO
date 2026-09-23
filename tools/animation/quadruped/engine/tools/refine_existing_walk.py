"""Generate, measure and render the existing V16 mesh with reusable refinement."""
import sys,json,hashlib,math,shutil
from pathlib import Path
import bpy
from mathutils import Vector
ENGINE=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ENGINE))
from quadruped_blender.refine_walk import generate
ROOT=Path.home()/"Documents/Roblox/DungeonMMO_CanineRig_QA/Frostfang_20260923/GroundedWalkTrial_20260923"
SOURCE=ROOT/"WalkV16_PawPadGait/Frostfang_WalkV16_UNAPPROVED.blend"
OUTPUT=ROOT/"ForelegRefinement_20260923"
CONFIG=ENGINE/"profiles/frostfang_v16_refinement.json"
def main():
    args=sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else []
    OUTPUT.mkdir(parents=True,exist_ok=True)
    dest=OUTPUT/"Frostfang_ForelegRefinement_REVIEW.blend"
    if "render" not in args:
        if dest.exists():raise FileExistsError(dest)
        source_hash=hashlib.sha256(SOURCE.read_bytes()).hexdigest()
        bpy.ops.wm.open_mainfile(filepath=str(SOURCE))
        rig=bpy.data.objects["Frostfang_Canine_CompactRig"]
        mesh=bpy.data.objects["Frostfang_Canine_ExperimentalMesh"]
        config=json.loads(CONFIG.read_text())
        records=generate(rig,config)
        scene=bpy.context.scene
        # Measure evaluated joints and weighted paw surface throughout every frame.
        groups={g.index:g.name for g in mesh.vertex_groups}
        pads={}
        for limb in config["limbs"]:
            pads[limb["id"]]=[v.index for v in mesh.data.vertices if any(groups[g.group] in (limb["toe"],limb["foot"]) and g.weight>.4 for g in v.groups)]
        result={"source":str(SOURCE),"source_sha256":source_hash,"mesh_vertices":len(mesh.data.vertices),"mesh_polygons":len(mesh.data.polygons),"frames":records,"limits":["Hind asymmetry and closed muzzle remain.","Blender authoring only; native Roblox playback not yet verified."]}
        for record in records:
            scene.frame_set(record["frame"]);bpy.context.view_layer.update()
            dg=bpy.context.evaluated_depsgraph_get()
            evaluated=mesh.evaluated_get(dg);surface=evaluated.to_mesh()
            for limb in config["limbs"]:
                item=record["limbs"][limb["id"]]
                upper=rig.pose.bones[limb["upper"]];lower=rig.pose.bones[limb["lower"]];foot=rig.pose.bones[limb["foot"]]
                item["actual_angle"]=math.degrees((upper.head-lower.head).angle(foot.head-lower.head))
                item["actual_ankle"]=list(rig.matrix_world @ foot.head)
                points=[evaluated.matrix_world @ surface.vertices[i].co for i in pads[limb["id"]]]
                item["pad_lowest"]=min(p.z for p in points)
            evaluated.to_mesh_clear()
        for limb in config["limbs"]:
            values=[r["limbs"][limb["id"]] for r in records]
            result[limb["id"]]={"angle_min":min(v["actual_angle"] for v in values),"angle_max":max(v["actual_angle"] for v in values),"angle_max_step":max(abs(a["actual_angle"]-b["actual_angle"]) for a,b in zip(values,values[1:])),"pad_min":min(v["pad_lowest"] for v in values),"stance_pad_max":max(v["pad_lowest"] for v in values if v["planted"]),"target_error":max((Vector(v["actual_ankle"])-Vector(v["target"])).length for v in values)}
        scene.frame_set(1)
        bpy.ops.wm.save_as_mainfile(filepath=str(dest))
        assert hashlib.sha256(SOURCE.read_bytes()).hexdigest()==source_hash
        (OUTPUT/"audit.json").write_text(json.dumps(result,indent=2))
        shutil.copy2(CONFIG,OUTPUT/"settings.json")
        shutil.copy2(ENGINE/"quadruped_blender/refine_walk.py",OUTPUT/"refine_walk.py")
        shutil.copy2(Path(__file__),OUTPUT/Path(__file__).name)
        print("REFINEMENT_AUDIT",json.dumps({k:result[k] for k in ("FrontLeft","FrontRight","HindLeft","HindRight")}),flush=True)
    else:bpy.ops.wm.open_mainfile(filepath=str(dest))
    if "render" in args or "stills" in args:
        render("stills" in args)
def render(stills):
    scene=bpy.context.scene
    scene.render.engine="BLENDER_WORKBENCH"
    scene.display.shading.light="STUDIO";scene.display.shading.color_type="MATERIAL"
    scene.display.shading.show_shadows=True
    scene.display.shading.show_cavity=True
    scene.render.resolution_x=700;scene.render.resolution_y=480;scene.render.resolution_percentage=100
    scene.render.image_settings.file_format="PNG"
    bpy.ops.mesh.primitive_plane_add(size=200,location=(0,0,0))
    bpy.context.object.name="QA_Floor"
    bpy.context.object.color=(.15,.17,.20,1)
    for obj in bpy.data.objects:
        if obj.type in ("ARMATURE","EMPTY"):obj.hide_render=True
    views={"side":((2.8,-.15,.65),(-.09,-.18,.48),1.95),
           "front":((-.10,-3,.65),(-.09,-.24,.48),1.65),
           "rear":((-.10,3,.65),(-.09,-.24,.48),1.65),
           "three_quarter":((2,-2,1),(-.09,-.18,.48),1.95),
           "foreleg_close":((2.4,-.52,.36),(-.09,-.53,.35),.92)}
    camera_data=bpy.data.cameras.new("RefinementReview")
    camera=bpy.data.objects.new("RefinementReview",camera_data);scene.collection.objects.link(camera)
    camera_data.type="ORTHO";scene.camera=camera
    frames=[1,79,84,89,101,113,125,scene.frame_end] if stills else range(1,scene.frame_end+1,2)
    for name,(pos,focus,scale) in views.items():
        directory=OUTPUT/"preview"/name;directory.mkdir(parents=True,exist_ok=True)
        camera.location=pos;camera.rotation_euler=(Vector(focus)-camera.location).to_track_quat("-Z","Y").to_euler()
        camera_data.ortho_scale=scale
        for f in frames:
            scene.frame_set(f);scene.render.filepath=str(directory/f"{f:04d}.png")
            bpy.ops.render.render(write_still=True)
        print("RENDERED",name,flush=True)
if __name__=="__main__":main()
