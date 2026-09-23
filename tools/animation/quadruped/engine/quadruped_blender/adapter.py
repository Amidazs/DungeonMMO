"""Measured rest-space adapter; never edits source anatomy or skinning."""
import json,hashlib
from mathutils import Vector
from quadruped_core.schema import validate
def rows(matrix):return [list(r) for r in matrix]
def calibrate(rig,profile):
    validate(profile,"profile")
    if rig.type!="ARMATURE":raise ValueError("select an armature")
    if abs(rig.matrix_world.determinant())<1e-10:raise ValueError("singular rig transform")
    scales=rig.matrix_world.to_scale()
    if max(scales)-min(scales)>1e-5:raise ValueError("apply nonuniform object scale on a working copy")
    names=set(profile["roles"].values())
    for group in profile["groups"].values():names.update(group)
    for limb in profile["limbs"].values():names.update(limb["chain"]);names.add(limb["paw"]);names.add(limb["toe"])
    absent=names-set(rig.data.bones.keys())
    if absent:raise ValueError("missing bones: "+", ".join(sorted(absent)))
    bones={b.name:dict(parent=b.parent.name if b.parent else None,rest=rows(b.matrix_local),
      head=list(b.head_local),tail=list(b.tail_local),length=b.length) for b in rig.data.bones}
    limbs={}
    for name,limb in profile["limbs"].items():
        chain=[rig.data.bones[n] for n in limb["chain"]]
        for i,b in enumerate(chain):
            if b.length<1e-7:raise ValueError("zero bone length "+b.name)
            if i and b.parent!=chain[i-1]:raise ValueError("disconnected chain "+name)
            if i and (b.head_local-chain[i-1].tail_local).length>1e-5:raise ValueError("joint gap "+name)
        points=[list(b.head_local) for b in chain]+[list(chain[-1].tail_local)]
        axis=Vector(limb["axis"]).normalized()
        if any(abs((b.tail_local-b.head_local).normalized().dot(axis))>.02 for b in chain):
            raise ValueError("limb axis is not perpendicular to measured plane: "+name)
        limbs[name]=dict(points=points,contact=points[-1],axis=list(axis),length=sum(b.length for b in chain))
    forward=Vector(profile["forward"]).normalized();up=Vector(profile["up"]).normalized()
    if abs(forward.dot(up))>.0001:raise ValueError("forward/up not orthogonal")
    return dict(profileId=profile["id"],bones=bones,limbs=limbs,
      scale=sum(l["length"] for l in limbs.values())/4,
      forward=list(forward),up=list(up),
      fingerprint=hashlib.sha256(json.dumps(bones,sort_keys=True).encode()).hexdigest())
