"""Deterministic editable FK generation with transactional rollback."""
import math,json
import bpy
from mathutils import Matrix,Vector,Quaternion
from quadruped_core.schema import validate
from quadruped_core.gait import sample_gait
from quadruped_core.pose import compose_pose
from quadruped_core.ik import solve_chain
from .adapter import calibrate

def reset_neutral(rig):
    if rig.animation_data:rig.animation_data.action=None
    for b in rig.pose.bones:b.matrix_basis=Matrix.Identity(4)
    bpy.context.view_layer.update()

def _group(rig,profile,group,world_axis,amplitude,phase,spread=0):
    names=profile["groups"].get(group,[])
    for i,name in enumerate(names):
        b=rig.pose.bones[name]
        local_axis=b.bone.matrix_local.to_quaternion().inverted()@world_axis
        b.rotation_mode="QUATERNION"
        b.rotation_quaternion=b.rotation_quaternion@Quaternion(local_axis,amplitude*math.sin(phase-i*spread)/max(1,len(names)))

def evaluate(rig,profile,definition,cal,time):
    for b in rig.pose.bones:b.matrix_basis=Matrix.Identity(4);b.rotation_mode="QUATERNION"
    p=definition["parameters"];sample=sample_gait(definition,cal,time)
    frequency=sample["cadence"] if sample["cadence"] else 1/definition["duration"]
    phase=2*math.pi*time*frequency
    forward=Vector(cal["forward"]);up=Vector(cal["up"]);right=forward.cross(up).normalized()
    root=rig.pose.bones[profile["roles"]["Root"]]
    shift=right*p.get("body_sway",0)*cal["scale"]*math.sin(phase)
    shift+=up*cal["scale"]*(p.get("body_bob",0)*math.sin(phase*2)+p.get("breathing",0)*math.sin(phase))
    if definition["rootMotion"]=="translate":shift+=Vector(sample["root"])
    root.location=root.bone.matrix_local.to_3x3().inverted()@shift
    _group(rig,profile,"spine",right,p.get("spine_pitch",0),phase)
    _group(rig,profile,"neck",right,p.get("neck_pitch",0),phase)
    _group(rig,profile,"head",up,p.get("head_yaw",0),phase)
    _group(rig,profile,"head",right,p.get("head_pitch",0),phase)
    _group(rig,profile,"tail",up,p.get("tail_yaw",0),phase,p.get("tail_phase",.6))
    _group(rig,profile,"tail",right,p.get("tail_pitch",0),phase,p.get("tail_phase",.6))
    _group(rig,profile,"jaw",right,p.get("jaw",0),phase)
    for role,channel in compose_pose({},definition.get("layers",[])).items():
        name=profile["roles"].get(role,role)
        if name not in rig.pose.bones:raise ValueError("pose bone missing: "+name)
        b=rig.pose.bones[name];b.rotation_quaternion=b.rotation_quaternion@Quaternion(channel["rotation"])
        b.location+=Vector(channel["translation"])*cal["scale"]
    bpy.context.view_layer.update()
    residuals={}
    for name,limb in profile["limbs"].items():
        if not limb.get("enabled",True):continue
        measured=cal["limbs"][name];upper=rig.pose.bones[limb["chain"][0]]
        parent_delta=upper.matrix@upper.bone.matrix_local.inverted()
        points=[list(parent_delta@Vector(v)) for v in measured["points"]]
        axis=list((parent_delta.to_quaternion()@Vector(measured["axis"])).normalized())
        target=sample["limbs"][name]["world" if definition["rootMotion"]=="translate" else "local"]
        result=solve_chain(dict(points=points,axis=axis),target,dict(limits=limb["limits"],iterations=80,tolerance=1e-5))
        residuals[name]=result["residual"]
        weight=limb.get("weight",1.)
        for i,bone_name in enumerate(limb["chain"]):
            b=rig.pose.bones[bone_name];old=b.matrix.copy()
            rest_direction=Vector(cal["bones"][bone_name]["tail"])-Vector(cal["bones"][bone_name]["head"])
            new_direction=Vector(result["points"][i+1])-Vector(result["points"][i])
            q=rest_direction.rotation_difference(new_direction)@b.bone.matrix_local.to_quaternion()
            desired=Matrix.Translation(Vector(result["points"][i]))@q.to_matrix().to_4x4()
            b.matrix=old.lerp(desired,weight)
            bpy.context.view_layer.update()
        paw=rig.pose.bones[limb["paw"]]
        old=paw.matrix.copy()
        desired=Matrix.Translation(Vector(result["points"][-1]))@paw.bone.matrix_local.to_quaternion().to_matrix().to_4x4()
        paw.matrix=old.lerp(desired,weight)
        bpy.context.view_layer.update()
    return residuals

def generate(rig,profile,definition,poses=None):
    validate(definition,"animation");cal=calibrate(rig,profile)
    rig.animation_data_create()
    old_action=rig.animation_data.action;old_frame=bpy.context.scene.frame_current
    old_basis={b.name:b.matrix_basis.copy() for b in rig.pose.bones}
    old_mode={b.name:b.rotation_mode for b in rig.pose.bones}
    if any(b.constraints for b in rig.pose.bones):raise ValueError("working rig has constraints; use a clean source copy or bake them first")
    action=bpy.data.actions.new("QAE_"+definition["id"]);action.use_fake_user=True
    try:
        rig.animation_data.action=action
        count=round(definition["duration"]*definition["fps"])
        maximum=0.
        for i in range(count+1):
            frame=i+1
            bpy.context.scene.frame_set(frame)
            errors=evaluate(rig,profile,definition,cal,i/definition["fps"])
            maximum=max(maximum,max(errors.values(),default=0.))
            for b in rig.pose.bones:
                b.keyframe_insert("location",frame=frame,group=b.name)
                b.keyframe_insert("rotation_quaternion",frame=frame,group=b.name)
                b.keyframe_insert("scale",frame=frame,group=b.name)
        action["quadruped_definition"]=json.dumps(definition)
        action["quadruped_profile"]=json.dumps(profile)
        action["max_contact_residual"]=maximum
        action.use_frame_range=True;action.frame_start=1;action.frame_end=count+1
        scene=bpy.context.scene;scene.frame_start=1;scene.frame_end=count
        scene.render.fps=definition["fps"];scene.frame_set(1)
        return action
    except Exception:
        rig.animation_data.action=old_action
        bpy.context.scene.frame_set(old_frame)
        for b in rig.pose.bones:b.rotation_mode=old_mode[b.name];b.matrix_basis=old_basis[b.name]
        bpy.data.actions.remove(action)
        raise
