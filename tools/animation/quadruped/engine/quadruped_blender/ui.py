"""Persistent owner-facing controls. UI operators delegate to reusable modules."""
import json,math,re,datetime
from pathlib import Path
import bpy
from bpy.props import StringProperty,FloatProperty,IntProperty,BoolProperty,EnumProperty,PointerProperty
from bpy_extras.io_utils import ImportHelper
from mathutils import Quaternion,Vector
from quadruped_core.storage import load,save
from .adapter import calibrate
from .authoring import generate,reset_neutral
from .export import export_bundle
ROOT=Path(__file__).resolve().parents[1]
if (Path(__file__).parent/"data").exists():ROOT=Path(__file__).parent/"data"
DEFAULT=str(Path.home()/"Documents/Roblox/DungeonMMO_Quadruped_AnimationEngine")
def rig_context(context):
    rig=context.object
    if not rig or rig.type!="ARMATURE":raise ValueError("Select the creature armature")
    return rig
def profile_for(s):
    p=load(Path(s.profile_path) if s.profile_path else ROOT/"profiles/frostfang_v3.json","profile")
    for name in p["limbs"]:
        p["limbs"][name]["enabled"]=getattr(s,"ik_"+name);p["limbs"][name]["weight"]=getattr(s,"weight_"+name)
    return p
PARAMETERS=("speed","stride","lift","cadence","stance","body_sway","body_bob","breathing","head_yaw","head_pitch","neck_pitch","spine_pitch","tail_yaw","tail_pitch","tail_phase","jaw")
def current_definition(s):
    p={n:getattr(s,n) for n in PARAMETERS};p["auto_cadence"]=s.auto_cadence
    p["phases"]={n:getattr(s,"phase_"+n) for n in ("FrontLeft","FrontRight","HindLeft","HindRight")}
    layers=[dict(pose=json.loads(s.pose_json),weight=s.pose_weight)] if s.use_pose and s.pose_json else []
    return dict(version=1,kind="animation",id=s.name,type=s.animation,duration=s.duration,fps=s.fps,
      loop=s.loop,rootMotion=s.root_motion,parameters=p,layers=layers,markers=[])
def filename(s):
    if not re.fullmatch(r"[A-Za-z0-9_-]{1,80}",s.name):raise ValueError("Name must use letters, numbers, - or _")
    return s.name+".json"
class Settings(bpy.types.PropertyGroup):
    profile_path:StringProperty(name="Rig profile",subtype="FILE_PATH")
    output_dir:StringProperty(name="Library",subtype="DIR_PATH",default=DEFAULT)
    name:StringProperty(name="Name",default="My_Wolf_Animation")
    animation:EnumProperty(name="Animation",items=[(n,n,"") for n in ("Idle","Walk","Run","Look","Tail","Custom")],default="Idle")
    root_motion:EnumProperty(name="Root motion",items=[("in_place","In place",""),("translate","Travel forward","")])
    duration:FloatProperty(name="Duration (s)",default=2,min=.05,max=120)
    fps:IntProperty(name="Frames/sec",default=30,min=1,max=120)
    loop:BoolProperty(name="Loop",default=True)
    auto_cadence:BoolProperty(name="Cadence from speed",default=True)
    speed:FloatProperty(name="Speed / leg length",default=.22,min=0,max=20)
    stride:FloatProperty(name="Stride / leg length",default=.44,min=.001,max=3)
    lift:FloatProperty(name="Step height",default=.07,min=0,max=1)
    cadence:FloatProperty(name="Cycles/sec",default=1,min=.01,max=20)
    stance:FloatProperty(name="Contact fraction",default=.65,min=.05,max=.95)
    body_sway:FloatProperty(name="Body sway",default=.004,min=0,max=.2)
    body_bob:FloatProperty(name="Body rise",default=.008,min=0,max=.2)
    breathing:FloatProperty(name="Breathing",default=.005,min=0,max=.1)
    head_yaw:FloatProperty(name="Head turn",default=.015,subtype="ANGLE",min=-1,max=1)
    head_pitch:FloatProperty(name="Head nod",default=.01,subtype="ANGLE",min=-1,max=1)
    neck_pitch:FloatProperty(name="Neck bend",default=.015,subtype="ANGLE",min=-1,max=1)
    spine_pitch:FloatProperty(name="Spine bend",default=.004,subtype="ANGLE",min=-.5,max=.5)
    tail_yaw:FloatProperty(name="Tail sway",default=.025,subtype="ANGLE",min=-1,max=1)
    tail_pitch:FloatProperty(name="Tail lift",default=.015,subtype="ANGLE",min=-1,max=1)
    tail_phase:FloatProperty(name="Tail follow-through",default=.6,min=0,max=3)
    jaw:FloatProperty(name="Jaw (rig limited)",default=0,subtype="ANGLE",min=-.5,max=.5)
    use_pose:BoolProperty(name="Layer saved pose",default=False)
    pose_weight:FloatProperty(name="Pose weight",default=1,min=0,max=1)
    pose_json:StringProperty(default="")
    status:StringProperty(default="Select the wolf armature to begin")
    bone:StringProperty(name="Bone")
    overwrite:BoolProperty(name="Replace existing preset",default=False)

for name,phase in (("FrontLeft",0),("FrontRight",.5),("HindLeft",.75),("HindRight",.25)):
    Settings.__annotations__["phase_"+name]=FloatProperty(name=name+" phase",default=phase,min=0,max=1)
    Settings.__annotations__["ik_"+name]=BoolProperty(name=name+" IK",default=True)
    Settings.__annotations__["weight_"+name]=FloatProperty(name="IK weight",default=1,min=0,max=1)

class SafeOperator:
    def execute(self,context):
        try:
            result=self.run(context);context.scene.qae.status=str(result or "Ready")
            return {"FINISHED"}
        except Exception as exc:
            context.scene.qae.status=str(exc);self.report({"WARNING"},str(exc));return {"CANCELLED"}
class Validate(SafeOperator,bpy.types.Operator):
    bl_idname="quadruped.validate";bl_label="Validate creature"
    def run(self,c):
        cal=calibrate(rig_context(c),profile_for(c.scene.qae));return "Mapped %d bones; experimental skin QA still required"%len(cal["bones"])
class Generate(SafeOperator,bpy.types.Operator):
    bl_idname="quadruped.generate";bl_label="Generate / Rebuild";bl_options={"REGISTER","UNDO"}
    def run(self,c):
        s=c.scene.qae;a=generate(rig_context(c),profile_for(s),current_definition(s))
        return a.name+" | contact residual %.5f"%a["max_contact_residual"]
class Reset(SafeOperator,bpy.types.Operator):
    bl_idname="quadruped.reset_neutral";bl_label="Reset neutral";bl_options={"REGISTER","UNDO"}
    def run(self,c):reset_neutral(rig_context(c))
class SaveAnimation(SafeOperator,bpy.types.Operator):
    bl_idname="quadruped.save_animation";bl_label="Save animation preset"
    def run(self,c):
        s=c.scene.qae;p=Path(s.output_dir)/"animations"/filename(s);save(p,current_definition(s),s.overwrite);return str(p)
class LoadAnimation(SafeOperator,bpy.types.Operator,ImportHelper):
    bl_idname="quadruped.load_animation";bl_label="Load animation preset"
    filename_ext=".json"
    def run(self,c):
        d=load(self.filepath,"animation");s=c.scene.qae
        s.name=d["id"];s.animation=d["type"];s.duration=d["duration"];s.fps=d["fps"];s.loop=d["loop"];s.root_motion=d["rootMotion"]
        defaults=json.loads((ROOT/"presets/animations/idle.json").read_text())["parameters"]
        for n in PARAMETERS:setattr(s,n,d["parameters"].get(n,defaults.get(n,0)))
        s.auto_cadence=d["parameters"].get("auto_cadence",True)
        for n,p in d["parameters"].get("phases",defaults["phases"]).items():setattr(s,"phase_"+n,p)
        s.use_pose=bool(d.get("layers"));s.pose_json=json.dumps(d["layers"][0]["pose"]) if s.use_pose else ""
        if s.use_pose:s.pose_weight=d["layers"][0]["weight"]
        return "Animation loaded and editable"
class SavePose(SafeOperator,bpy.types.Operator):
    bl_idname="quadruped.save_pose";bl_label="Save current pose"
    def run(self,c):
        s=c.scene.qae;rig=rig_context(c);profile=profile_for(s);cal=calibrate(rig,profile)
        selected=[b for b in rig.pose.bones if b.select] or list(rig.pose.bones)
        aliases={v:k for k,v in profile["roles"].items()}
        channels={aliases.get(b.name,b.name):dict(rotation=list(b.matrix_basis.to_quaternion()),translation=[v/cal["scale"] for v in b.matrix_basis.translation]) for b in selected}
        p=dict(version=1,kind="pose",id=s.name,profileId=profile["id"],family=profile["family"],channels=channels,mask=list(channels))
        path=Path(s.output_dir)/"poses"/filename(s);save(path,p,s.overwrite);return str(path)
class LoadPose(SafeOperator,bpy.types.Operator,ImportHelper):
    bl_idname="quadruped.load_pose";bl_label="Load / Layer pose";filename_ext=".json"
    def run(self,c):
        p=load(self.filepath,"pose");s=c.scene.qae;rig=rig_context(c);profile=profile_for(s);cal=calibrate(rig,profile)
        for role in p["mask"]:
            if profile["roles"].get(role,role) not in rig.pose.bones:raise ValueError("pose bone absent: "+role)
        reset_neutral(rig)
        for role in p["mask"]:
            b=rig.pose.bones[profile["roles"].get(role,role)];b.rotation_mode="QUATERNION"
            b.rotation_quaternion=Quaternion(p["channels"][role]["rotation"])
            b.location=Vector(p["channels"][role]["translation"])*cal["scale"]
        s.pose_json=json.dumps(p);s.use_pose=True;return "Pose loaded; next Generate layers it"
class Export(SafeOperator,bpy.types.Operator):
    bl_idname="quadruped.bake_export";bl_label="Bake and export"
    def run(self,c):
        s=c.scene.qae;rig=rig_context(c)
        if not rig.animation_data or not rig.animation_data.action:raise ValueError("Generate or select an engine action first")
        from .bake import bake
        action=rig.animation_data.action
        baked=bake(rig,action,round(action.frame_start),round(action.frame_end))
        dest=Path(s.output_dir)/"exports"/(Path(filename(s)).stem+"_"+datetime.datetime.now().strftime("%Y%m%d_%H%M%S_%f"))
        return str(export_bundle(rig,profile_for(s),baked,dest))
class SelectBone(SafeOperator,bpy.types.Operator):
    bl_idname="quadruped.select_bone";bl_label="Edit selected bone"
    def run(self,c):
        rig=rig_context(c);name=c.scene.qae.bone
        if name not in rig.data.bones:raise ValueError("choose a bone")
        if c.mode!="POSE":bpy.ops.object.mode_set(mode="POSE")
        for b in rig.pose.bones:b.select=b.name==name
        rig.data.bones.active=rig.data.bones[name];rig.pose.bones[name].rotation_mode="XYZ"
class Panel(bpy.types.Panel):
    bl_label="Quadruped Animation Studio";bl_idname="QAE_PT_main";bl_space_type="VIEW_3D";bl_region_type="UI";bl_category="Quadruped"
    def draw(self,c):
        l=self.layout;s=c.scene.qae
        l.prop(s,"profile_path");l.operator("quadruped.validate")
        l.prop(s,"output_dir");l.prop(s,"name");l.prop(s,"animation")
        row=l.row();row.prop(s,"duration");row.prop(s,"fps")
        l.prop(s,"root_motion");l.prop(s,"loop")
        row=l.row();row.operator("screen.animation_play",text="Play / Pause");row.prop(c.scene,"frame_current",text="Frame")
        l.prop(c.scene.render,"fps_base",text="Playback time scale")
        l.operator("quadruped.generate");l.operator("quadruped.reset_neutral")
        box=l.box();box.label(text="Locomotion")
        for n in ("speed","stride","lift","auto_cadence","cadence","stance","body_sway","body_bob","breathing"):box.prop(s,n)
        box=l.box();box.label(text="Head, neck, spine and full tail")
        for n in ("head_yaw","head_pitch","neck_pitch","spine_pitch","tail_yaw","tail_pitch","tail_phase","jaw"):box.prop(s,n)
        box=l.box();box.label(text="Individual limbs")
        for n in ("FrontLeft","FrontRight","HindLeft","HindRight"):
            box.prop(s,"ik_"+n);row=box.row();row.prop(s,"phase_"+n);row.prop(s,"weight_"+n)
        box=l.box();box.label(text="Pose editor")
        if c.object and c.object.type=="ARMATURE":
            box.prop_search(s,"bone",c.object.data,"bones");box.operator("quadruped.select_bone")
            b=c.object.pose.bones.get(s.bone)
            if b:
                box.prop(b,"location",text="Offset")
                box.prop(b,"rotation_euler" if b.rotation_mode=="XYZ" else "rotation_quaternion",text="Rotation")
        box.prop(s,"use_pose");box.prop(s,"pose_weight")
        row=box.row();row.operator("quadruped.save_pose");row.operator("quadruped.load_pose")
        l.prop(s,"overwrite")
        row=l.row();row.operator("quadruped.save_animation");row.operator("quadruped.load_animation")
        l.operator("quadruped.bake_export")
        l.label(text=s.status[:65],icon="INFO")
CLASSES=(Settings,Validate,Generate,Reset,SaveAnimation,LoadAnimation,SavePose,LoadPose,Export,SelectBone,Panel)
def register():
    for cls in CLASSES:bpy.utils.register_class(cls)
    bpy.types.Scene.qae=PointerProperty(type=Settings)
def unregister():
    if hasattr(bpy.types.Scene,"qae"):del bpy.types.Scene.qae
    for cls in reversed(CLASSES):bpy.utils.unregister_class(cls)
