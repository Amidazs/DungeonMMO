"""Export baked editable clips and lossless local mesh packets; never uploads."""
import json,math,datetime
from pathlib import Path
import bpy
from mathutils import Matrix
from .adapter import calibrate
from .bake import bake
C=Matrix(((1,0,0,0),(0,0,1,0),(0,-1,0,0),(0,0,0,1)))
def matrix_values(m,scale=6.):
    converted=C@m@C.inverted();converted.translation*=scale
    return [converted[0][3],converted[1][3],converted[2][3]]+[converted[i][j] for i in range(3) for j in range(3)]
def export_bundle(rig,profile,action,destination):
    destination=Path(destination)
    if destination.exists():raise FileExistsError("export folder exists")
    cal=calibrate(rig,profile);destination.mkdir(parents=True)
    definition=json.loads(action["quadruped_definition"]);scene=bpy.context.scene
    old_action=rig.animation_data.action;old_frame=scene.frame_current
    bones=[dict(name=b.name,parent=b.parent.name if b.parent else None,
      bind=matrix_values(b.matrix_local),local=matrix_values(b.parent.matrix_local.inverted()@b.matrix_local if b.parent else b.matrix_local))
      for b in rig.data.bones]
    frames=[]
    try:
        rig.animation_data.action=action
        for frame in range(round(action.frame_start),round(action.frame_end)+1):
            scene.frame_set(frame);bpy.context.view_layer.update()
            frames.append(dict(time=(frame-1)/definition["fps"],poses={b.name:matrix_values(b.matrix_basis,6.) for b in rig.pose.bones},
              world={b.name:matrix_values(b.matrix,6.) for b in rig.pose.bones}))
        manifest=dict(version=1,kind="clip",id=definition["id"],profileId=profile["id"],
          fingerprint=cal["fingerprint"],loop=definition["loop"],duration=definition["duration"],fps=definition["fps"],
          bones=bones,frames=frames,meshFiles=[],coordinateConvention="Blender(x,y,z) -> Roblox(x,z,-y), scale 6",
          limitations=["Experimental rig deformation is not repaired.","EditableMesh local import requires runtime rehydration and skin adapter."])
        # Raw rest geometry and exact skin weights, sectioned by triangles.
        meshes=[o for o in bpy.data.objects if o.type=="MESH" and any(m.type=="ARMATURE" and m.object==rig for m in o.modifiers)]
        if not meshes:raise ValueError("no bound source mesh")
        for obj in meshes:
            mesh=obj.data;mesh.calc_loop_triangles()
            image_nodes=[n for mat in mesh.materials if mat and mat.use_nodes for n in mat.node_tree.nodes if n.type=="TEX_IMAGE" and n.image]
            for node in image_nodes:
                if not node.image.packed_file and node.image.filepath and not Path(bpy.path.abspath(node.image.filepath)).exists():
                    raise ValueError("missing external texture "+node.image.filepath)
            groups={g.index:g.name for g in obj.vertex_groups}
            transform=rig.matrix_world.inverted()@obj.matrix_world
            for start in range(0,len(mesh.loop_triangles),14000):
                triangles=mesh.loop_triangles[start:start+14000];indices=sorted({v for tri in triangles for v in tri.vertices});lookup={v:i+1 for i,v in enumerate(indices)}
                vertices=[]
                for index in indices:
                    v=mesh.vertices[index];p=C@transform@v.co
                    influences=[(groups[g.group],g.weight) for g in v.groups if groups[g.group] in cal["bones"] and g.weight>1e-8]
                    if not influences or len(influences)>4:raise ValueError("invalid skin influence budget")
                    vertices.append(dict(p=[float(x*6) for x in p],bones=[a for a,b in influences],weights=[b for a,b in influences]))
                faces=[]
                uv=mesh.uv_layers.active
                for tri in triangles:
                    faces.append(dict(v=[lookup[v] for v in tri.vertices],uv=[list(uv.data[l].uv) if uv else [0,0] for l in tri.loops]))
                filename="mesh_%02d.json"%len(manifest["meshFiles"])
                (destination/filename).write_text(json.dumps(dict(vertices=vertices,faces=faces),separators=(",",":")))
                manifest["meshFiles"].append(filename)
        (destination/"manifest.json").write_text(json.dumps(manifest,separators=(",",":")))
        (destination/"definition.json").write_text(json.dumps(definition,indent=2))
        (destination/"profile.json").write_text(json.dumps(profile,indent=2))
        # Animation-only FBX on actual deformation rig. Mesh packets preserve
        # full geometry for local QA; original full mesh exceeds Studio limits.
        selected=list(bpy.context.selected_objects);active=bpy.context.view_layer.objects.active
        try:
            bpy.ops.object.select_all(action="DESELECT");rig.select_set(True);bpy.context.view_layer.objects.active=rig
            scene.frame_start=round(action.frame_start);scene.frame_end=round(action.frame_end)
            bpy.ops.export_scene.fbx(filepath=str(destination/"animation.fbx"),use_selection=True,object_types={"ARMATURE"},
              add_leaf_bones=False,bake_anim=True,bake_anim_use_all_actions=False,bake_anim_use_nla_strips=False,
              bake_anim_simplify_factor=0,axis_forward="-Z",axis_up="Y")
        finally:
            bpy.ops.object.select_all(action="DESELECT")
            for o in selected:o.select_set(True)
            bpy.context.view_layer.objects.active=active
        return destination/"manifest.json"
    finally:
        rig.animation_data.action=old_action;scene.frame_set(old_frame)
