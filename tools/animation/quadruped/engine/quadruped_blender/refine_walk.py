"""Refine an existing controlled quadruped without replacing its mesh or rest rig.

Mapping and separate fore/hind settings are JSON data. Existing hind IK and
world paw controls are retained. Forelegs use measured two-link, pole-directed
IK with continuous scapular support. Operates on an already opened COPY.
"""
import math,json
import bpy
from mathutils import Vector, Quaternion, Matrix
from quadruped_core.refinement import timeline, contact, smooth, two_bone

def key_pose(bone, frame):
    bone.rotation_mode="QUATERNION"
    for path in ("location","rotation_quaternion","scale"):
        bone.keyframe_insert(data_path=path,frame=frame)

def aim(bone, head, tail):
    matrix=bone.matrix.copy()
    rotation=(matrix.to_3x3() @ Vector((0,1,0))).rotation_difference(tail-head)
    result=rotation.to_matrix().to_4x4() @ matrix
    result.translation=head
    bone.matrix=result
    bpy.context.view_layer.update()

def generate(rig, config):
    for limb in config["limbs"]:
        for role in ("upper","lower","foot","toe"):
            if limb[role] not in rig.pose.bones:raise ValueError("Missing mapped bone: "+limb[role])
        for role in ("target","orientation"):
            if limb[role] not in bpy.data.objects:raise ValueError("Missing control: "+limb[role])
    scene=bpy.context.scene
    scene.frame_set(1)
    bpy.context.view_layer.update()
    if "qae_refinement_neutral" not in rig:
        rig["qae_refinement_neutral"]=json.dumps(dict(origin=list(rig.location),
            bases={b.name:[list(row) for row in b.matrix_basis] for b in rig.pose.bones},
            controls={limb["id"]:dict(position=list(bpy.data.objects[limb["target"]].location),
                rotation=list(bpy.data.objects[limb["orientation"]].rotation_quaternion)) for limb in config["limbs"]}))
    neutral=json.loads(rig["qae_refinement_neutral"])
    origin=Vector(neutral["origin"])
    bases={name:Matrix(value) for name,value in neutral["bases"].items()}
    controls={}
    for limb in config["limbs"]:
        target=bpy.data.objects[limb["target"]]
        reference=bpy.data.objects[limb["orientation"]]
        controls[limb["id"]]=(target,reference,Vector(neutral["controls"][limb["id"]]["position"])-Vector((0,0,limb.get("ground_offset",0))),Quaternion(neutral["controls"][limb["id"]]["rotation"]))
    rig.animation_data_clear()
    for target,reference,_,_ in controls.values():
        target.animation_data_clear();reference.animation_data_clear()
    for limb in config["limbs"]:
        if limb["family"]=="front":
            for constraint in rig.pose.bones[limb["lower"]].constraints:
                if constraint.type=="IK":constraint.mute=True
    fps=config.get("fps",24)
    scene.render.fps=fps
    walk_end=timeline(100,**config["timeline"])["walk_end"]
    duration=walk_end+config.get("settle",1.2)+1
    scene.frame_start=1;scene.frame_end=round(duration*fps)+1
    records=[]
    for frame in range(1,scene.frame_end+1):
        scene.frame_set(frame)
        t=(frame-1)/fps;state=timeline(t,**config["timeline"])
        q=state["cycles"];weight=state["weight"]
        # A small anticipatory load transfer precedes root travel.
        anticipation=smooth((t-config["timeline"]["idle"]+.25)/.25)*(1-smooth((t-config["timeline"]["idle"])/.6))
        travel=q*config["root_stride"]
        rig.location=origin+Vector((0,-travel,(-config.get("body_drop",.014)+.001*(1-math.cos(4*math.pi*q)))*max(weight,anticipation)))
        for name,basis in bases.items():rig.pose.bones[name].matrix_basis=basis
        bpy.context.view_layer.update()
        frame_record={"frame":frame,"time":t,"cycles":q,"limbs":{}}
        for limb in config["limbs"]:
            settings=config[limb["family"]]
            target,reference,rest,rest_rotation=controls[limb["id"]]
            local_q=travel/settings["stride"]
            sample=contact(local_q,dict(settings,offset=limb["offset"]))
            position=rest+Vector((0,-sample["forward"],sample["height"]))
            flex=math.radians(settings["paw_flex"])*math.sin(math.pi*sample["swing"])**2
            # Complete a short final recovery step if the selected stride differs.
            if state["finished"]:
                final=rest+Vector((0,-travel,0))
                s=smooth((t-walk_end)/config.get("settle",1.2))
                position=position.lerp(final,s)
                position.z+=settings["lift"]*math.sin(math.pi*s)**2 if (position-final).length>.00001 else 0
                flex*=1-s
                sample["planted"]=s==1 or (position-final).length<.00001
            target.location=position
            reference.rotation_mode="QUATERNION"
            reference.rotation_quaternion=Quaternion(Vector((1,0,0)),flex) @ rest_rotation
            target.keyframe_insert(data_path="location",frame=frame)
            reference.keyframe_insert(data_path="rotation_quaternion",frame=frame)
            bpy.context.view_layer.update()
            if limb["family"]=="front":
                shoulder=rig.pose.bones[limb["shoulder"]]
                phase=sample["phase"]
                sweep=(1-2*smooth(phase/settings["stance"])) if phase<settings["stance"] else (-1+2*smooth((phase-settings["stance"])/(1-settings["stance"])))
                shoulder.rotation_mode="QUATERNION"
                shoulder.rotation_quaternion=shoulder.rotation_quaternion @ Quaternion(Vector((1,0,0)),math.radians(settings["shoulder_sweep"])*sweep*weight)
                bpy.context.view_layer.update()
                upper=rig.pose.bones[limb["upper"]];lower=rig.pose.bones[limb["lower"]]
                goal=rig.matrix_world.inverted() @ position
                start=upper.head.copy()
                a=upper.bone.length;b=lower.bone.length
                limit=settings["joint_limit"]
                reach=math.sqrt(a*a+b*b-2*a*b*math.cos(math.radians(limit)))
                horizontal=(start.x-goal.x)**2+(start.y-goal.y)**2
                allowed=math.sqrt(max(.00001,reach*reach-horizontal))
                excess=max(0,start.z-goal.z-allowed)
                # Continuous soft support avoids the old discrete rotation gate.
                support=excess+.001*weight+.0015*anticipation
                matrix=shoulder.matrix.copy();matrix.translation.z-=support
                shoulder.matrix=matrix
                bpy.context.view_layer.update()
                start=upper.head.copy()
                solved=two_bone(tuple(start),tuple(goal),a,b,tuple(limb["pole"]),limit)
                elbow=Vector(solved["elbow"]);end=Vector(solved["end"])
                aim(upper,start,elbow);aim(lower,elbow,end)
                frame_record["limbs"][limb["id"]]={"elbow":solved["angle"],"residual":solved["residual"],"support":support}
            else:
                # Existing two-link hind IK, rest proportions and bend branch.
                frame_record["limbs"][limb["id"]]={}
            frame_record["limbs"][limb["id"]].update(planted=sample["planted"],target=list(position))
        # Preserve hind IK branch; limit extension with measured pelvis support.
        support=0.
        for limb in config["limbs"]:
            if limb["family"]!="hind":continue
            upper=rig.pose.bones[limb["upper"]];lower=rig.pose.bones[limb["lower"]]
            goal=rig.matrix_world.inverted() @ controls[limb["id"]][0].location
            start=upper.head;angle=math.radians(config["hind"]["joint_limit"])
            reach2=upper.bone.length**2+lower.bone.length**2-2*upper.bone.length*lower.bone.length*math.cos(angle)
            z=math.sqrt(max(.00001,reach2-(start.x-goal.x)**2-(start.y-goal.y)**2))
            support=max(support,start.z-goal.z-z)
        if support>0:
            pelvis=rig.pose.bones[config["pelvis"]]
            matrix=pelvis.matrix.copy();matrix.translation.z-=support+.0001
            pelvis.matrix=matrix;bpy.context.view_layer.update()
        for bone in rig.pose.bones:key_pose(bone,frame)
        rig.keyframe_insert(data_path="location",frame=frame)
        records.append(frame_record)
    if rig.animation_data and rig.animation_data.action:
        action=rig.animation_data.action
        action.name="QAE_Foreleg_Refinement_Idle_Walk4_Idle"
        action.use_fake_user=True
        action.use_frame_range=True;action.frame_start=1;action.frame_end=scene.frame_end
        action["quadruped_refinement"]=json.dumps(config)
        action["quadruped_definition"]=json.dumps(dict(version=1,kind="animation",id="Frostfang_Foreleg_Refinement",type="Walk",
            duration=(scene.frame_end-1)/fps,fps=fps,loop=False,rootMotion="translate",parameters={},layers=[],markers=[]))
    scene.frame_set(1)
    return records
