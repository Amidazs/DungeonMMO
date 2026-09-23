"""Read-only source/candidate surface and joint comparison."""
import json,sys,hashlib,math
from pathlib import Path
import bpy,numpy as np
from mathutils import Vector
ROOT=Path.home()/"Documents/Roblox/DungeonMMO_CanineRig_QA/Frostfang_20260923/GroundedWalkTrial_20260923"
OUT=ROOT/"ForelegRefinement_20260923_D"
def fingerprint(mesh,rig):
    h=hashlib.sha256()
    for v in mesh.data.vertices:
        h.update(repr(tuple(v.co)).encode())
        h.update(repr([(g.group,g.weight) for g in v.groups]).encode())
    for p in mesh.data.polygons:h.update(repr(tuple(p.vertices)).encode())
    for b in rig.data.bones:h.update(repr((b.name,list(map(tuple,b.matrix_local)))).encode())
    return h.hexdigest()
def inspect(path,records=None):
    bpy.ops.wm.open_mainfile(filepath=str(path))
    scene=bpy.context.scene;rig=bpy.data.objects["Frostfang_Canine_CompactRig"];mesh=bpy.data.objects["Frostfang_Canine_ExperimentalMesh"]
    names={g.index:g.name for g in mesh.vertex_groups}
    selected={v.index for v in mesh.data.vertices if any(names[g.group].startswith(("DEF_shoulder","DEF_front_thigh")) and g.weight>.1 for g in v.groups)}
    edges=np.array([list(e.vertices) for e in mesh.data.edges if all(i in selected for i in e.vertices)])
    rest=np.array([list(v.co) for v in mesh.data.vertices])
    lengths=np.linalg.norm(rest[edges[:,0]]-rest[edges[:,1]],axis=1)
    valid=lengths>.0005;edges=edges[valid];lengths=lengths[valid]
    maxima=[];counts=[];first={};last={};drift={};previous={}
    for f in range(scene.frame_start,scene.frame_end+1):
        scene.frame_set(f)
        obj=mesh.evaluated_get(bpy.context.evaluated_depsgraph_get());data=obj.to_mesh()
        coords=np.empty(len(data.vertices)*3,dtype=np.float32);data.vertices.foreach_get("co",coords);coords=coords.reshape((-1,3))
        ratios=np.linalg.norm(coords[edges[:,0]]-coords[edges[:,1]],axis=1)/lengths
        maxima.append(float(np.max(ratios)));counts.append(int(np.sum(ratios>1.5)))
        if records:
            for limb in records[f-1]["limbs"]:
                target=Vector(records[f-1]["limbs"][limb]["actual_ankle"])
                if records[f-1]["limbs"][limb]["planted"]:
                    if limb in previous:drift[limb]=max(drift.get(limb,0),(target-previous[limb]).length)
                    previous[limb]=target
                else:previous.pop(limb,None)
        matrices={b.name:[list(row) for row in b.matrix] for b in rig.pose.bones}
        if f==scene.frame_start:first=matrices
        if f==scene.frame_end:last=matrices
        obj.to_mesh_clear()
    return dict(fingerprint=fingerprint(mesh,rig),shoulder_edges=len(edges),max_edge_stretch=max(maxima),max_edges_over_150_percent=max(counts),
      frame_stretch=maxima,stance_ankle_step=drift,neutral_return_matrix_error=max(abs(a-b) for n in first for r,s in zip(first[n],last[n]) for a,b in zip(r,s)),
      objects=[dict(name=o.name,type=o.type) for o in scene.objects])
a=inspect(ROOT/"WalkV16_PawPadGait/Frostfang_WalkV16_UNAPPROVED.blend")
b=inspect(OUT/"Frostfang_ForelegRefinement_REVIEW.blend",json.loads((OUT/"audit.json").read_text())["frames"])
result=dict(source=a,candidate=b,mesh_skin_and_rest_skeleton_unchanged=a["fingerprint"]==b["fingerprint"])
(OUT/"surface_comparison.json").write_text(json.dumps(result,indent=2))
print("SURFACE_COMPARISON",json.dumps({k:{n:v for n,v in value.items() if n!="frame_stretch"} if isinstance(value,dict) else value for k,value in result.items()}),flush=True)
